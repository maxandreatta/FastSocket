//
//  ConnectionProtocol.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
import Network

/// ConnectionProtocol is the conformance for the FastSocket Protocol `Engine`
/// this will be used to implement a fallback with foundation in the future
internal protocol ConnectionProtocol: AnyObject {
    /// the events
    var delegate: ConnectionDelegate? { get set }
    /// create a instance of Connection
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    ///     - parameters: NWParameters `optional`
    ///     - queue: Dispatch Qeue `optional`
    init(host: String, port: UInt16, parameters: NWParameters, queue: DispatchQueue)
    /// connect to a host
    /// prevent reconnecting after a connection
    /// was successfully established
    func connect()
    /// disconnect from host and
    /// cleanup the connection
    func disconnect()
    /// write data async on tcp socket
    /// slices big data into chunks and send it stacked
    /// - parameters:
    ///     - data: the data which should be written on the socket
    func send(data: Data, _ completion: @escaping () -> Void)
}
