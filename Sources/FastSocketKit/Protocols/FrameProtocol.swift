//
//  FrameProtocol.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 29.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation

// 0          1            N
// +----------+------------+
// |0|1 2 3 4 | 0 1 2 3... |
// +-+--------+------------+
// |O| FRAME  |  PAYLOAD   |
// |P| LENGTH |    (N)     |
// |C|  (4)   |            |
// +-+--------+------------+
// : Payload continued...  :
// + - - - - - - - - - - - +
// | Payload continued...  |
// +-----------------------+
//
// This describes the framing protocol.
// - OPC:
//      - 0x0: this is the continue byte (currently a placeholder)
//      - 0x1: this is the string byte which is used for string based messages
//      - 0x2: this is the data byte which is used for data based messages
//      - 0x3: this is the fin byte, which is part of OPC
//      - 0x6 - 0xF: this bytes are reserved
// - FRAME LENGTH:
//      - this uses 8 bytes to store the entire frame size as a big endian uint32 value
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
    func create<T: Message>(message: T) throws -> Data
    /// parse a FastSocket Protocol compliant messsage back to it's raw data
    /// - parameters:
    ///     - data: the received data
    func parse(data: Data, _ completion: (Message) -> Void) throws
}
