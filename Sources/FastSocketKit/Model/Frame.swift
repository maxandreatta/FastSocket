//
//  Frame.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation

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
//      - 0x3: this is the fin byte, which is part of OPC but is on the first place in the protocol
//      - 0x6 - 0xFF: this bytes are reserved
// - FRAME LENGTH:
//      - this uses 4 bytes to store the entire frame size as a big endian uint32 value
// - PAYLOAD:
//      - continued payload data

/// Frame is a helper class for the FastSocket Protocol
/// it is used to create new message frames or to parse
/// received Data back to it's raw type
internal final class Frame: FrameProtocol {
    private var buffer = Data()
    /// private property to get parse the overhead size of a frame
    private var size: UInt32 {
        guard buffer.count >= Constant.overheadSize else { return .zero }
        let size = Data(buffer[.one...Constant.overheadSize.penultimate])
        return size.integer
    }
    // boolean which indicates if buffer is empty and can be flushed
    private var empty: Bool { buffer.count <= size }
    /// helper for frame
    /// trims a frame to it's raw content
    private func trim(data: Data) -> Data? {
        guard data.count >= Constant.overheadSize else { return nil }
        return Data(data[Constant.overheadSize...Int(size.penultimate)])
    }
    /// crate instance of Frame
    internal required init() {
        // needs strong reference
    }
    /// generic func to create a fastsocket protocol compliant
    /// message frame
    /// - parameters:
    ///     - message: generic parameter, accepts string and data
    internal func create<T: Message>(message: T) throws -> Data {
        var frame = Data()
        frame.append(message.opcode)
        frame.append(UInt32(message.raw.count + Constant.overheadSize).data)
        frame.append(message.raw)
        guard frame.count <= Constant.frameSize else {
            throw FastSocketError.writeBufferOverflow
        }
        return frame
    }
    /// parse a FastSocket Protocol compliant messsage back to it's raw data
    /// - parameters:
    ///     - data: the received data
    internal func parse(data: Data, _ completion: (Message) -> Void) throws {
        guard !data.isEmpty else {
            throw FastSocketError.zeroData
        }
        buffer.append(data)
        let size = self.size
        guard buffer.count <= Constant.frameSize else {
            throw FastSocketError.readBufferOverflow
        }
        guard buffer.count >= Constant.overheadSize, buffer.count >= size else { return }
        while buffer.count >= size && size != .zero {
            if buffer.first == Opcode.string.rawValue {
                guard let bytes = trim(data: buffer), let message = String(bytes: bytes, encoding: .utf8) else {
                    throw FastSocketError.parsingFailure
                }
                completion(message)
            }
            if buffer.first == Opcode.data.rawValue {
                guard let message = trim(data: buffer) else {
                    throw FastSocketError.parsingFailure
                }
                completion(message)
            }
            if empty { buffer = Data() } else { buffer = Data(buffer[size...]) }
        }
    }
}
