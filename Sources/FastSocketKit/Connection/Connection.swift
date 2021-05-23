//
//  NetworkTransfer.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
import Network

/// Connection is a raw TCP transfer
/// it uses the Network.framework. This is
/// the `Engine` of the FastSocket Protocol.
/// It allows to enter directly the TCP Options
internal final class Connection: ConnectionProtocol {
    internal weak var delegate: ConnectionDelegate?
    private var connection: NWConnection
    private var monitor = NWPathMonitor()
    private var state: NWConnection.State?
    private var queue: DispatchQueue
    private var running: Bool = false
    private var processed: Bool = true
    /// create a instance of Connection
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    ///     - parameters: NWParameters `optional`
    ///     - queue: Dispatch Qeue `optional`
    required init(host: String, port: UInt16, parameters: NWParameters = .tcp, queue: DispatchQueue = DispatchQueue(label: Constant.prefix.unique, qos: .userInitiated)) {
        self.connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(integerLiteral: port), using: parameters)
        self.queue = queue
    }
    /// connect to a host
    /// prevent reconnecting after a connection
    /// was successfully established
    internal func connect() {
        guard !running else { return }
        running = true
        status_handler()
        path_handler()
        receive()
        connection.start(queue: queue)
    }
    /// disconnect from host and
    /// cleanup the connection
    internal func disconnect() {
        clean()
    }
    /// write data async on tcp socket
    /// slices big data into chunks and send it stacked
    /// - parameters:
    ///     - data: the data which should be written on the socket
    internal func send(data: Data, _ completion: @escaping () -> Void) {
        guard let delegate = self.delegate else { return }
        guard state == .ready else {
            delegate.didGetError(FastSocketError.sendToEarly)
            return
        }
        guard processed else { return }
        processed = false
        let queued = data.chunk
        guard !queued.isEmpty else { return }
        for (i, data) in queued.enumerated() {
            self.connection.send(content: data, completion: .contentProcessed({ error in
                if let error = error {
                    guard error != NWError.posix(.ECANCELED) else { return }
                    delegate.didGetError(error)
                    return
                }
                self.delegate?.didGetBytes(Bytes(output: data.count))
                if i == queued.endIndex.penultimate {
                    self.processed = true
                    completion()
                }
            }))
        }
    }
    // MARK: - extension for private functions
    /// cleanup a connection
    private func clean() {
        running = false
        connection.cancel()
    }
    /// check connection state
    private func status_handler() {
        guard let delegate = self.delegate else { return }
        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            self.state = state
            switch state {
            case .ready:
                delegate.didGetReady()
            case .failed(let error):
                delegate.didGetError(error)
            case .cancelled:
                delegate.didGetClose()
            default:
                break
            }
        }
    }
    /// a network path monitor
    /// used to detect if network is unrechable
    private func path_handler() {
        guard let delegate = self.delegate else { return }
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            guard path.status == .unsatisfied else { return }
            self.clean()
            delegate.didGetError(FastSocketError.networkUnreachable)
        }
        monitor.start(queue: DispatchQueue(label: Constant.prefix.unique, qos: .userInitiated))
    }
    /// readloop for the tcp socket incoming data
    private func receive() {
        guard let delegate = self.delegate else { return }
        guard running else { return }
            self.connection.receive(minimumIncompleteLength: Constant.minimumIncompleteLength, maximumLength: Constant.maximumLength) { [weak self] data, _, is_complete, error in
                guard let self = self else { return }
                if let error = error {
                    guard error != NWError.posix(.ECANCELED) else { return }
                    delegate.didGetError(error)
                    self.clean()
                    return
                }
                if let data = data {
                    delegate.didGetData(data)
                    delegate.didGetBytes(Bytes(input: data.count))
                }
                if is_complete { self.clean() } else { self.receive() }
        }
    }
}
