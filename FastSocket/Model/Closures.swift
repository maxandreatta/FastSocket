//
//  Closures.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
/// TransferClosures are used by the network transfer
internal struct TransferClosures {
    /// called if the connection is ready
    internal var ready: Callback = { }
    /// called if the connection was closed
    internal var close: Callback = { }
    /// called if data is provided
    internal var data: CallbackData = { data in }
    /// called if bytes are written or readed from the socket
    internal var bytes: CallbackBytes = { bytes in }
    /// called if an error is provided
    internal var error: CallbackError = { error in }
}
/// FastSocketClosures are used by the Protocol to provide
/// necessary features
public struct FastSocketClosures {
    /// called if the connection is ready
    public var ready: Callback = { }
    /// called if the connection was closed
    public var close: Callback = { }
    /// called if a data or string based message was received
    public var message: CallbackMessage = { message in }
    /// called if bytes are written or readed from the socket
    internal var bytes: CallbackBytes = { bytes in }
    /// called if an error is provided
    public var error: CallbackError = { error in }
}
