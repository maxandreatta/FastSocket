//
//  Core.swift
//  CustomTCP
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation
import Network

// TODO: Document

public class FastSocket {
    public var on: FastSocketEvents = FastSocketEvents()
    private var frame: Frame = Frame()
    private var transfer: TransferProtocol
    private var queue: DispatchQueue
    private var socketKey: String = "6D8EDFD9-541C-4391-9171-AD519876B32E"
    private var locked = false
    public required init(host: NWEndpoint.Host, port: NWEndpoint.Port) {
        self.transfer = NetworkStream(host: host, port: port)
        self.queue = DispatchQueue(label: "Core.Socket.Dispatch.\(UUID().uuidString)", qos: .background, attributes: .concurrent)
    }
    
    public func connect() {
        self.frame = Frame()
        self.transferListner()
        self.messageListener()
        self.transfer.connect()
    }
    
    public func disconnect() {
        self.transfer.disconnect()
    }
        
    public func send(data: Data) {
        guard self.locked == true else {
            self.on.error(SocketError.sendToEarly)
            return
        }
        let frame = self.frame.create(data: data, opcode: .binary)
        self.transfer.send(data: frame)
    }
    
    public func send(text: String) {
        guard self.locked == true else {
            self.on.error(SocketError.sendToEarly)
            return
        }
        let frame = self.frame.create(data: text.data(using: .utf8)!, opcode: .text)
        self.transfer.send(data: frame)
    }
}

private extension FastSocket {
    private func handShake() {
        let keyData = self.socketKey.data(using: .utf8)
        self.transfer.send(data: keyData!)
    }

    private func transferListner() {
        self.transfer.on.ready = {
            self.handShake()
        }
        self.transfer.on.data = { data in
            if self.locked == true {
                self.frame.parse(data: data)
            }
            if self.locked == false {
                guard data[0] == ControlCode.accept.rawValue else {
                    self.disconnect()
                    self.on.error(SocketError.handShakeFailed)
                    self.on.error(SocketError.socketUnexpectedClosed)
                    return
                }
                self.locked = true
                self.on.ready()
            }
        }
        self.transfer.on.close = {
            self.on.close()
        }
        self.transfer.on.error = { error in
            self.on.error(error)
        }
        self.transfer.on.inputData = { bytesCount in
            self.on.receivedData(bytesCount)
        }
        self.transfer.on.outputData = { bytesCount in
            self.on.writtenData(bytesCount)
        }
    }
    
    private func messageListener() {
        self.frame.onTextFrame = { data in
            guard let string = String(data: data, encoding: .utf8) else {
                self.on.error(SocketError.parsingFailure)
                return
            }
            self.on.text(string)
        }
        
        self.frame.onBinaryFrame = { data in
            self.on.binary(data)
        }
    }
}
