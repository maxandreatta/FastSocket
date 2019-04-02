//
//  Error.swift
//  CustomTCP
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation

public enum SocketError: Int, Error {
    case none = 0
    case handShakeFailed = 1
    case timeoutError = 2
    case sendFailed = 3
    case sendToEarly = 4
    case socketClosed = 5
    case socketUnexpectedClosed = 6
    case parsingFailure = 7
}

extension SocketError: CustomNSError {
    public static var errorDomain: String { return "fastSocket.error" }
    public var errorCode: Int { return self.rawValue }
    public var errorUserInfo: [String: Any] {
        switch self {
        case .none:
            return [NSLocalizedDescriptionKey: "null"]
        case .handShakeFailed:
            return [NSLocalizedDescriptionKey: "handshake failure, not FastSocket compliant"]
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
        }
    }
}
