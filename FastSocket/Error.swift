//
//  Error.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
/// Error handling for the FastSocket Protocol
public enum FastSocketError: Int, Error {
    /// none is a placeholder
    case none = 0
    /// thrown if handshake is failed
    case handShakeFailed = 100
    /// thrown on connection timeout
    case timeoutError = 101
    /// thrown if sending failed
    case sendFailed = 200
    /// thrown if sending before connection is ready
    case sendToEarly = 201
    /// thrown if socket was closed (maybe for internal use)
    case socketClosed = 202
    /// thrown if socket was closed not normally
    case socketUnexpectedClosed = 203
    /// thrown if message parsing failed
    case parsingFailure = 300
    /// thrown if message parser get's zer0 data
    case zeroData = 301
    /// thrown if message type was unknown
    case invalidMessageType = 302
    /// thrown if opcode was unknown
    case unknownOpcode = 1000
}

extension FastSocketError: CustomNSError {
    public static var errorDomain: String { return "fastsocket.error" }
    public var errorCode: Int { return self.rawValue }
    public var errorUserInfo: [String: Any] {
        switch self {
        case .none:
            return [NSLocalizedDescriptionKey: "null"]

        case .handShakeFailed:
            return [NSLocalizedDescriptionKey: "handshake failure, not protocol compliant"]

        case .timeoutError:
            return [NSLocalizedDescriptionKey: "connection timeout error"]

        case .sendFailed:
            return [NSLocalizedDescriptionKey: "send failure, data was not written"]

        case .sendToEarly:
            return [NSLocalizedDescriptionKey: "socket is not ready, could not send"]

        case .socketClosed:
            return [NSLocalizedDescriptionKey: "socket was closed"]

        case .socketUnexpectedClosed:
            return [NSLocalizedDescriptionKey: "socket was unexpected closed"]

        case .parsingFailure:
            return [NSLocalizedDescriptionKey: "message parsing error, no valid UTF-8"]

        case .zeroData:
            return [NSLocalizedDescriptionKey: "data is empty cannot parse into message"]

        case .invalidMessageType:
            return [NSLocalizedDescriptionKey: "unknown opcode for message type, cannot parse message"]

        case .unknownOpcode:
            return [NSLocalizedDescriptionKey: "unknown opcode, cannot parse message"]
        }
    }
}
