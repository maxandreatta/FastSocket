//
//  FastSocket.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
import Network

/// FastSocket is a proprietary communication protocol directly
/// written on top of TCP. It's a message based protocol which allows you
/// to send text and binary based messages. The protocol is so small it have
/// only 5 Bytes overhead per message, the handshake is done directly on TCP level.
/// The motivation behind this protocol was, to use it as `Performance Protocol`, a
/// low level TCP communication protocol to measure TCP throughput performance. -> FastSockets is the answer
/// FastSocket allows to enter all possible TCP Options if needed and is completely non-blocking and async, thanks to GCD.
public final class FastSocket: FastSocketProtocol {
    /// access to the event based closures
    public var on = FastSocketCallback()
    /// parameters provides full access to the Network.framework
    /// NWParameters object. Overwrite with .paramters = .tls if
    /// a secure TLS connection is required
    public var parameters: NWParameters = .tcp
    private var host: String
    private var port: UInt16
    private var frame = Frame()
    private var transfer: TransferProtocol?
    private var timer: DispatchSourceTimer?
    private var digest = Data()
    private var isLocked = false
    private var queue = DispatchQueue(label: "\(Constant.prefixFrame).\(UUID().uuidString)")
    /// create a instance of FastSocket
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    public required init(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }
    /// connect to the server
    /// try to establish a connection to a
    /// FastSocket compliant server
    public func connect() {
        initialize()
        guard let transfer = transfer else { return }
        transfer.connect()
        startTimeout()
    }
    /// disconnect from the server
    /// closes the connection `normally`
    public func disconnect() {
        guard let transfer = transfer else { return }
        transfer.disconnect()
        stopTimeout()
    }
    /// generic send function, send data or string based messages
    /// - parameters:
    ///     - message: generic type (accepts data or string)
    ///     - completion: callback when data was processed by the stack `optional`
    public func send<T: Message>(message: T, _ completion: (() -> Void)? = nil) {
        guard isLocked, let transfer = transfer else { return }
        self.queue.async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try self.frame.create(message: message)
                transfer.send(data: data) {
                    guard let completion = completion else { return }
                    completion()
                }
            } catch {
                self.onError(error)
            }
        }
    }
}

// MARK: - extension for private functions
private extension FastSocket {
    /// private func to reset all needed values
    /// and initialize
    private func initialize() {
        guard !host.isEmpty else {
            onError(FastSocketError.emptyHost)
            return
        }
        isLocked = false
        digest = Data()
        transfer = NetworkTransfer(host: host, port: port, parameters: parameters)
        callbacks()
    }
    /// suspends timeout and report on error
    /// - parameters:
    ///     - error: the error `optional`
    private func onError(_ error: Error?) {
        if let timer = timer {
            timer.cancel()
        }
        guard let error = error else { return }
        on.error(error)
        disconnect()
    }
    /// send the handshake frame
    private func handshake() {
        guard let transfer = transfer else { return }
        guard let data = UUID().uuidString.data(using: .utf8) else {
            onError(FastSocketError.handshakeInitializationFailed)
            return
        }
        digest = data.sha256
        transfer.send(data: data) { /* idempotent */ }
    }
    /// start timeout on connecting
    private func startTimeout() {
        timer = Timer.interval(interval: Constant.timeout, withRepeat: false) {
            self.onError(FastSocketError.timeoutError)
        }
    }
    /// stop timeout
    private func stopTimeout() {
        guard let timer = timer else { return }
        timer.cancel()
    }
}

// MARK: - extension for closure handling
private extension FastSocket {
    /// closures from the transfer protocol
    /// handles incoming data and handshake
    private func callbacks() {
        guard let transfer = transfer else { return }
        transfer.on.ready = { [weak self] in
            guard let self = self else { return }
            self.handshake()
        }
        transfer.on.message = { [weak self] data in
            guard let self = self else { return }
            guard case let data as Data = data else { return }
            switch self.isLocked {
            case true:
                self.queue.async { [weak self] in
                    guard let self = self else { return }
                    do {
                        try self.frame.parse(data: data) { message in
                            self.on.message(message)
                        }
                    } catch {
                        self.onError(error)
                    }
                }
            case false:
                guard data == self.digest else {
                    self.onError(FastSocketError.handshakeVerificationFailed)
                    return
                }
                self.isLocked = true
                self.stopTimeout()
                self.on.ready()
            }
        }
        transfer.on.close = on.close
        transfer.on.bytes = on.bytes
        transfer.on.error = onError
    }
}
