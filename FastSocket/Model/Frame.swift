//
//  Frame.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
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
//      - 0x3: this is the fin byte, which is part of OPC but is on the first place in the protocol
//      - 0x6 - 0xF: this bytes are reserved
// - FRAME LENGTH:
//      - this uses 8 bytes to store the entire frame size as a big endian uint64 value
// - PAYLOAD:
//      - continued payload data

/// Frame is a helper class for the FastSocket Protocol
/// it is used to create new message frames or to parse
/// received Data back to it's raw type
internal final class Frame: FrameProtocol {
    internal var onMessage: (MessageProtocol) -> Void = { message in }
    private var readBuffer = Data()
    /// private property to get parse the overhead size of a frame
    private var contentSize: UInt64 {
        guard readBuffer.count >= Constant.overheadSize else {
            return .zero
        }
        let size = Data(readBuffer[1...Constant.overheadSize - 1])
        return size.intValue()
    }
    /// crate instance of Frame
    internal required init() {
        // needs strong reference
    }
    /// generic func to create a fastsocket protocol compliant
    /// message frame
    /// - parameters:
    ///     - message: generic parameter, accepts string and data
    internal func create<T: MessageProtocol>(message: T) throws -> Data {
        var frame = Data()
        switch message {
        case let message as String:
            let message = message.utf8
            frame.append(Opcode.string.rawValue)
            frame.append(UInt64(message.count + Constant.overheadSize).data)
            frame.append(message)
        case let message as Data:
            frame.append(Opcode.data.rawValue)
            frame.append(UInt64(message.count + Constant.overheadSize).data)
            frame.append(message)
        default:
            throw FastSocketError.unknownOpcode
        }
        guard frame.count <= Constant.maximumContentLength else {
            throw FastSocketError.writeBufferOverflow
        }
        return frame
    }
    /// parse a FastSocket Protocol compliant messsage back to it's raw data
    /// - parameters:
    ///     - data: the received data
    internal func parse(data: Data) throws {
        guard !data.isEmpty else {
            throw FastSocketError.zeroData
        }
        readBuffer.append(data)
        guard readBuffer.count <= Constant.maximumContentLength else {
            throw FastSocketError.readBufferOverflow
        }
        guard readBuffer.count >= Constant.overheadSize, readBuffer.count >= contentSize else { return }
        while readBuffer.count >= contentSize && contentSize != .zero {
            let slice = Data(readBuffer[...(contentSize - 1)])
            switch slice.first {
            case Opcode.string.rawValue:
                guard let bytes = slice.trim, let message = String(bytes: bytes, encoding: .utf8) else {
                    throw FastSocketError.parsingFailure
                }
                onMessage(message)
            case Opcode.data.rawValue:
                guard let message = slice.trim else {
                    throw FastSocketError.parsingFailure
                }
                onMessage(message)
            default:
                throw FastSocketError.unknownOpcode
            }
            if readBuffer.count > contentSize {
                readBuffer = Data(readBuffer[contentSize...])
            } else {
                readBuffer = Data()
            }
        }
    }
}
