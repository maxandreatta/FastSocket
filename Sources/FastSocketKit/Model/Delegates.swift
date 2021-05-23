//
//  Closures.swift
//  Octanium
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation

/// Delegate for Connection
internal protocol ConnectionDelegate: AnyObject {
    /// called if the connection is ready
    func didGetReady()
    /// called if the connection was closed
    func didGetClose()
    /// called if raw data is ready from the connection
    func didGetData(_ data: Data)
    /// called if bytes are written or readed from the socket
    func didGetBytes(_ bytes: Bytes)
    /// called if an error is provided
    func didGetError(_ error: Error?)
}

/// Delegate for Octanium
public protocol OctaniumDelegate: AnyObject {
    /// called if the connection is ready
    func didGetReady()
    /// called if the connection was closed
    func didGetClose()
    /// called if a data or string based message was received
    func didGetMessage(_ message: Message)
    /// called if bytes are written or readed from the socket
    func didGetBytes(_ bytes: Bytes)
    /// called if an error is provided
    func didGetError(_ error: Error?)
}
