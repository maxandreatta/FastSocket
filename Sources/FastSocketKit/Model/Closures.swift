//
//  Closures.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation

/// FastSocketClosures are used by the Protocol to provide
/// necessary features
public struct Closures {
    /// called if the connection is ready
    public var ready: () -> Void = { }
    /// called if the connection was closed
    public var close: () -> Void = { }
    /// called if a data or string based message was received
    public var message: (Message) -> Void = { message in }
    /// called if bytes are written or readed from the socket
    public var bytes: (Bytes) -> Void = { bytes in }
    /// called if an error is provided
    public var error: (Error?) -> Void = { error in }
}
