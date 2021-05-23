//
//  Octanium.swift
//  Octanium
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
import Network

/// Octanium is a proprietary communication protocol directly
/// written on top of TCP. It's a message based protocol which allows you
/// to send text and binary based messages. The protocol is so small it have
/// only 5 Bytes overhead per message, the handshake is done directly on TCP level.
/// The motivation behind this protocol was, to use it as `Performance Protocol`, a
/// low level TCP communication protocol to measure TCP throughput performance. -> FastSockets is the answer
/// Octanium allows to enter all possible TCP Options if needed and is completely non-blocking and async, thanks to GCD.
public final class Octanium: OctaniumProtocol {
    /// access to the event based closures
    public var delegate: OctaniumDelegate?
    public var parameters: NWParameters = .tcp
    ///private variables
    private var host: String
    private var port: UInt16
    private var frame = Frame()
    private var connection: ConnectionProtocol?
    private var timer: DispatchSourceTimer?
    private var digest = Data()
    private var locked = false
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
    /// Octanium compliant server
    public func connect() {
        setup()
        guard let connection = connection else { return }
        connection.delegate = self
        connection.open()
        startTimeout()
    }
    /// disconnect from the server
    /// closes the connection `normally`
    public func disconnect() {
        guard let connection = connection else { return }
        connection.close()
        stopTimeout()
    }
    /// generic send function, send data or string based messages
    /// - parameters:
    ///     - message: generic type (accepts data or string)
    ///     - completion: callback when data was processed by the stack `optional`
    public func send<T: Message>(message: T, _ completion: (() -> Void)? = nil) {
        guard locked, let connection = connection else { return }
        
        let data = self.frame.create(message: message) { error in self.onError(error) }
        connection.send(data: data) {
            guard let completion = completion else { return }
            completion()
        }
    }
    // MARK: - extension for private functions

    /// private func to reset all needed values
    /// and initialize
    private func setup() {
        guard !host.isEmpty else {
            onError(FastSocketError.emptyHost)
            return
        }
        guard port != .zero else {
            onError(FastSocketError.zeroPort)
            return
        }
        locked = false
        connection = Connection(host: host, port: port, parameters: parameters)
    }
    /// suspends timeout and report on error
    /// - parameters:
    ///     - error: the error `optional`
    private func onError(_ error: Error?) {
        if let timer = timer {
            timer.cancel()
        }
        guard let error = error else { return }
        guard let delegate = self.delegate else { return }
        delegate.didGetError(error)
        disconnect()
    }
    /// send the handshake frame
    private func handshake() {
        guard let connection = connection else { return }
        guard let data = UUID().uuidString.data(using: .utf8) else {
            onError(FastSocketError.handshakeInitializationFailed)
            return
        }
        digest = data.sha256
        connection.send(data: data, nil)
    }
    /// start timeout on connecting
    private func startTimeout() {
        timer = Timer.interval(interval: Constant.timeout) {
            self.onError(FastSocketError.timeoutError)
        }
    }
    /// stop timeout
    private func stopTimeout() {
        guard let timer = timer else { return }
        timer.cancel()
    }
}

// MARK: - Delegates
extension Octanium: ConnectionDelegate {
    func didGetReady() {
        self.handshake()
    }
    
    func didGetClose() {
        guard let delegate = self.delegate else { return }
        delegate.didGetClose()
    }
    
    func didGetData(_ data: Data) {
        guard let delegate = self.delegate else { return }
        switch self.locked {
        case true:
            self.frame.parse(data: data) { message, error in
                if let error = error { self.onError(error) }
                if let message = message { delegate.didGetMessage(message) }
            }
        case false:
            guard data == self.digest else {
                self.onError(FastSocketError.handshakeVerificationFailed)
                return
            }
            self.locked = true
            self.stopTimeout()
            delegate.didGetReady()
        }
    }
    
    func didGetBytes(_ bytes: Bytes) {
        guard let delegate = self.delegate else { return }
        delegate.didGetBytes(bytes)
    }
    
    func didGetError(_ error: Error?) {
        guard let delegate = self.delegate else { return }
        delegate.didGetError(error)
    }
}
