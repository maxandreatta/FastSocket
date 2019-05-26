//
//  Frame.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
import Foundation

// 0                   1       N
// +-------------------+-------+
// |0|1|2 3 4 5 6 7 8 9|0 1 2 3|
// +-+-+---------------+-------+
// |F|O| FRAME LENGTH  |PAYLOAD|
// |I|P|     (8)       |  (N)  |
// |N|C|               |       |
// +-+-+---------------+-------+
// : Payload Data continued ...:
// + - - - - - - - - - - - - - +
// | Payload Data continued ...|
// +---------------------------+
//
// This describes the framing protocol.
// - FIN: 0x3
//      - The first byte is used to inform the the other side, that the
//        connection is finished and can be closed, this is used to prevent
//        that a connection will be closed but there are unread bytes on the connection
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
    internal var onMessage: CallbackMessage = { message in }
    private var readBuffer = Data()

    internal required init() {
    }
    /// generic func to create a fastsocket protocol compliant
    /// message frame
    /// - parameters:
    ///     - message: generic parameter, accepts string and data
    ///     - isFinal: send a close frame to the host default is false
    internal func create<T: MessageTypeProtocol>(message: T, isFinal: Bool = false) throws -> Data {
        var outputFrame = Data()
        switch isFinal {
        case true:
            outputFrame.append(Opcode.finish.rawValue)

        case false:
            outputFrame.append(Opcode.continue.rawValue)
        }
        switch message {
        case let message as String:
            try buildStringMessage(frame: &outputFrame, message: message)

        case let message as Data:
            buildDataMessage(frame: &outputFrame, message: message)

        default:
            throw FastSocketError.unknownOpcode
        }
        guard outputFrame.count <= Constant.maximumContentLength else {
            throw FastSocketError.writeBufferOverflow
        }
        return outputFrame
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
        guard readBuffer.count >= Constant.overheadSize else {
            return
        }
        guard readBuffer.count >= contentSize() else {
            return
        }
        while readBuffer.count >= contentSize() && contentSize() != .zero {
            let slice = Data(readBuffer[...(contentSize() - 1)])
            switch slice[1] {
            case Opcode.string.rawValue:
                guard let string = String(bytes: try trimFrame(frame: slice), encoding: .utf8) else {
                    throw FastSocketError.parsingFailure
                }
                onMessage(string)

            case Opcode.data.rawValue:
                onMessage(try trimFrame(frame: slice))

            default:
                throw FastSocketError.unknownOpcode
            }
            if readBuffer.count > contentSize() {
                readBuffer = Data(readBuffer[contentSize()...])
            } else {
                readBuffer = Data()
            }
        }
    }
}

private extension Frame {
    /// build a string based message, appends the necessary data
    /// to the original reference
    /// - parameters:
    ///     - frame: the original data frame, this is a reference to the value
    ///     - message: the original text message
    private func buildStringMessage(frame: inout Data, message: String) throws {
        guard let message = message.data(using: .utf8) else {
            throw FastSocketError.parsingFailure
        }
        frame.append(Opcode.string.rawValue)
        frame.append(UInt64(message.count + Constant.overheadSize).data)
        frame.append(message)
    }
    /// build a data based message, appends the necessary data
    /// to the original reference
    /// - parameters:
    ///     - frame: the original data frame, this is a reference to the value
    ///     - message: the original data message
    private func buildDataMessage(frame: inout Data, message: Data) {
        frame.append(Opcode.data.rawValue)
        frame.append(UInt64(message.count + Constant.overheadSize).data)
        frame.append(message)
    }
    /// private function to get parse the overhead size of a frame
    /// - parameters:
    ///     - data: data to extract content size from
    private func contentSize() -> UInt64 {
        guard readBuffer.count >= Constant.overheadSize else {
            return .zero
        }
        let size = Data(readBuffer[2...Constant.overheadSize - 1])
        return size.intValue()
    }
    /// private func to trimm frame to it's raw content
    /// - parameters:
    ///     - frame: the data to trimm
    private func trimFrame(frame: Data) throws -> Data {
        guard frame.count >= Constant.overheadSize else {
            throw FastSocketError.parsingFailure
        }
        let data = Data(frame[Constant.overheadSize...])
        return data
    }
}
