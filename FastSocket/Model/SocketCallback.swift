//
//  SocketCallback.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
/// FastSocketClosures are used by the Protocol to provide
/// necessary features
public struct SocketCallback {
    /// called if the connection is ready
    public var ready: FastSocketCallback = { }
    /// called if the connection was closed
    public var close: FastSocketCallback = { }
    /// called if a data or string based message was received
    public var message: FastSocketCallbackMessage = { message in }
    /// called if bytes are written or readed from the socket
    public var bytes: FastSocketCallbackBytes = { bytes in }
    /// called if an error is provided
    public var error: FastSocketCallbackError = { error in }
}
