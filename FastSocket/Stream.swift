//
//  Stream.swift
//  CustomTCP
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation
import Network

/// Network Stream is a raw TCP Transfer
/// which was implemented by using the Network.framework
/// from Apple. Conformance to the TransferProtocol
internal class NetworkStream: TransferProtocol {
    private var connection: NWConnection
    private var queue: DispatchQueue
    private var isRunning: Bool = false
    private var isConnected: Bool = false
    private var connectionState: NWConnection.State = .cancelled
    internal var on: NetworkStreamEvents = NetworkStreamEvents()
    required init(host: NWEndpoint.Host, port: NWEndpoint.Port, using: NWParameters = NWParameters(tls: nil), queue: DispatchQueue = DispatchQueue(label: "NetworkCore.Queue.\(UUID().uuidString)", qos: .userInteractive, attributes: .concurrent)) {
        self.connection = NWConnection(host: host, port: port, using: using)
        self.queue = queue
    }
    
    internal func connect() {
        self.isConnected = false
        func doConnect(_ error: Error?) {
            if !isConnected {
                self.on.error(error)
                isConnected = true
                isRunning = true
            } else {
                isRunning = false
            }
        }
        self.connection.stateUpdateHandler = { state in
            self.connectionState = state
            switch state {
            case .ready:
                self.on.ready()
                doConnect(nil)
            case .waiting(let error):
                self.on.error(error)
            case .cancelled:
                doConnect(nil)
            case .failed(let error):
                doConnect(error)
            case .setup, .preparing:
                break
            }
        }
        self.connection.start(queue: self.queue)
        self.isRunning = true
        self.readLoop()
    }
    
    internal func disconnect() {
        self.connection.cancel()
        self.on.close()
    }
    
    internal func send(data: Data) {
        guard self.connectionState == .ready  else { print("Connection is \(self.connectionState), not ready to send..."); return }
        let queued = data.chunked(by: Constant.maximumLength)
        for i in 0...queued.count - 1 {
            self.connection.send(content: Data(queued[i]), completion: .contentProcessed({ error in
                self.on.dataInput(queued[i].count)
            }))
        }
    }
}

extension NetworkStream {
    private func clean() {
        self.isRunning = false
        self.connection.cancel()
    }
    
    private func readLoop() {
        if !self.isRunning {
            return
        }

        self.connection.receive(minimumIncompleteLength: Constant.minimumIncompleteLength, maximumLength: Constant.maximumLength, completion: {[weak self] (data, context, isComplete, error) in
            guard let s = self else {return}
            if let err = error {
                s.on.error(err)
                return
            }
            if let data = data {
                s.on.data(data)
                s.on.dataInput(data.count)
            }
            // this is the indicator, that the connection is dead and will be closed
            if isComplete && data == nil, context == nil, error == nil {
                s.on.close()
                s.clean()
                return
            }
            s.readLoop()
        })
    }
}
