//
//  TransferType.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 13.05.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
/// the network transfer type
public enum TransferType {
    /// TCP is the default transfer type.
    /// This transfer type is used for unencrypted connections
    /// for the best throughput performance.
    case tcp
    /// TLS is for encrypted connections.
    /// The usage of TLS has impact of the throughput performance
    /// but it's very secure. The host must run TLS.
    case tls
}
