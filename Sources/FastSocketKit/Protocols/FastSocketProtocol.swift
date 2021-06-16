//
//  FastSocketProtocol.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 16.04.19.
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
public protocol FastSocketProtocol: class {
    /// public access to the event based closures
    var on: FastSocketCallback { get set }
    /// parameters provides full access to the Network.framework
    /// NWParameters object. Overwrite with .paramters = .tls if
    /// a secure TLS connection is required
    var parameters: NWParameters { get set }
    /// create a instance of FastSocket
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    init(host: String, port: UInt16)
    /// connect to the server
    /// try to establish a connection to a
    /// FastSocket compliant server
    func connect(timeout:Int)
    /// disconnect from the server
    /// closes the connection `normally`
    func disconnect()
    /// generic send function, send data or string based messages
    /// - parameters:
    ///     - message: generic type (accepts data or string)
    ///     - completion: callback when data was processed by the stack `optional`
    func send<T: Message>(message: T, _ completion: (() -> Void)?)
}
