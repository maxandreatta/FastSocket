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
    public var callback: OctaniumCallback = OctaniumCallback()
    public var parameters: NWParameters = .tcp
    ///private variables
    private var host: String
    private var port: UInt16
    private var qos: DispatchQoS
    private var frame: Frame = Frame()
    private var connection: ConnectionProtocol?
    private var timer: DispatchSourceTimer?
    private var digest: Data = Data()
    private var locked: Bool = false
    /// create a instance of Octanium
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    public required init(host: String, port: UInt16, qos: DispatchQoS = .background) {
        self.host = host
        self.port = port
        self.qos = qos
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
            onError(OctaniumError.emptyHost)
            return
        }
        guard port != .zero else {
            onError(OctaniumError.zeroPort)
            return
        }
        locked = false
        connection = Connection(host: host, port: port, parameters: parameters, qos: qos)
    }
    /// suspends timeout and report on error
    /// - parameters:
    ///     - error: the error `optional`
    private func onError(_ error: Error?) {
        if let timer = timer {
            timer.cancel()
        }
        guard let error = error else { return }
        callback.didGetError(error)
        disconnect()
    }
    /// send the handshake frame
    private func handshake() {
        guard let connection = connection else { return }
        guard let data = UUID().uuidString.data(using: .utf8) else {
            onError(OctaniumError.handshakeInitializationFailed)
            return
        }
        digest = data.sha256
        connection.send(data: data, nil)
    }
    /// start timeout on connecting
    private func startTimeout() {
        timer = Timer.interval(interval: Constant.timeout) {
            self.onError(OctaniumError.timeoutError)
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
    /// perform ready action
    func didGetReady() {
        self.handshake()
    }
    /// perform close action
    func didGetClose() {
        callback.didGetClose()
    }
    /// perform data action
    /// - Parameter data: received data
    func didGetData(_ data: Data) {
        switch self.locked {
        case true:
            self.frame.parse(data: data) { message, error in
                if let error = error { self.onError(error) }
                if let message = message { callback.didGetMessage(message) }
            }
        case false:
            guard data == self.digest else {
                self.onError(OctaniumError.handshakeVerificationFailed)
                return
            }
            self.locked = true
            self.stopTimeout()
            callback.didGetReady()
        }
    }
    /// perform bytes action
    func didGetBytes(_ bytes: Bytes) {
        callback.didGetBytes(bytes)
    }
    /// perform error action
    func didGetError(_ error: Error?) {
        callback.didGetError(error)
    }
}
