//
//  FrameProtocol.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 29.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation

// 0                 1       N
// +-----------------+-------+
// |0|1 2 3 4 5 6 7 8|0 1 2 3|
// +-+---------------+-------+
// |O| FRAME LENGTH  |PAYLOAD|
// |P|     (8)       |  (N)  |
// |C|               |       |
// +-+---------------+-------+
// :Payload Data continued...:
// + - - - - - - - - - - - - +
// |Payload Data continued...|
// +-------------------------+
//
// This describes the framing protocol.
// - OPC:
//      - 0x0: this is the continue byte (currently a placeholder)
//      - 0x1: this is the string byte which is used for string based messages
//      - 0x2: this is the data byte which is used for data based messages
//      - 0x3: this is the fin byte, which is part of OPC
//      - 0x6 - 0xF: this bytes are reserved
// - FRAME LENGTH:
//      - this uses 8 bytes to store the entire frame size as a big endian uint64 value
// - PAYLOAD:
//      - continued payload data

/// The framing protocol
internal protocol FrameProtocol: class {
    // create instance of Frame
    init()
    /// generic func to create a fastsocket protocol compliant
    /// message frame
    /// - parameters:
    ///     - message: generic parameter, accepts string and data
    func create<T: MessageProtocol>(message: T) throws -> Data
    /// parse a FastSocket Protocol compliant messsage back to it's raw data
    /// - parameters:
    ///     - data: the received data
    func parse(data: Data, _ completion: (MessageProtocol) -> Void) throws
}
