//
//  Constants.swift
//  FastSocket
//
//  Created by Romero, Juan, SEVEN PRINCIPLES on 04.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
/// Constants used by the protocol
internal enum Constant {
    /// queue prefix for network
    static let prefixNetwork = "network.dispatch."
    /// queue prefix for timer
    static let prefixTimer = "timer.dispatch"
    /// queue prefix for iteration
    static let prefixIteration = "iteration.dispatch"
    /// for tcp socket reading, minimum stream length
    static let minimumIncompleteLength: Int = 1
    /// maximum tcp readbuffer size
    static let maximumLength: Int = 16_384
    /// timeout time
    static let timeout: TimeInterval = 3.0
    /// maximum per message size
    static let maximumContentLength: Int = 16_777_216
    /// framing overhead
    static let overheadSize: Int = 5
    /// maximum iteration size
    static let iterations: Int = 256
    /// minimum chunk size
    static let minimumChunkSize: Int = 8192
}
