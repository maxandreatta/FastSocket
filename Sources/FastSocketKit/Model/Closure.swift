//
//  Closure.swift
//  FastSocketKit
//
//  Created by Vinzenz Weist on 23.05.21.
//

import Foundation

/// FastSocketClosures are used by the Protocol to provide
/// necessary features
public struct OctaniumCallback {
    /// called if the connection is ready
    public var didGetReady: () -> Void = { }
    /// called if the connection was closed
    public var didGetClose: () -> Void = { }
    /// called if a data or string based message was received
    public var didGetMessage: (Message) -> Void = { message in }
    /// called if bytes are written or readed from the socket
    public var didGetBytes: (Bytes) -> Void = { bytes in }
    /// called if an error is provided
    public var didGetError: (Error?) -> Void = { error in }
}
