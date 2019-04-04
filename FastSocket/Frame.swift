//
//  Frame.swift
//  CustomTCP
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation
/*
 Propritary Messaging Protocol `Speedtest Protocol` Framing
 
 +---+------------------------------+-+
 |0 1|         ... Continue         |N|
 +---+------------------------------+-+
 | O |                              |F|
 | P |         Payload Data...      |I|
 | C |                              |N|
 | O |         Payload Data...      |B|
 | D |                              |Y|
 | E |         Payload Data...      |T|
 |   |                              |E|
 |   |         Payload Data...      | |
 |   |                              | |
 +---+------------------------------+-+
 */
internal class Frame {
    // TODO: Generify this
    internal var onBinaryFrame: (_ data: Data) -> () = { _ in }
    internal var onTextFrame: (_ data: Data) -> () = { _ in }
    internal var outputFrame: Data = Data()
    internal var inputFrame: Data = Data()
    internal var readBuffer: Data = Data()

    internal init() {
    }

    internal func create(data: Data, opcode: Opcode) -> Data {
        self.outputFrame = Data()
        self.outputFrame.append(opcode.rawValue)
        self.outputFrame.append(ControlCode.continue.rawValue)
        self.outputFrame.append(data)
        self.outputFrame.append(ControlCode.finish.rawValue)
        return self.outputFrame
    }
    
    internal func parse(data: Data) {
        guard data.count > 0 else {
            // TODO: Throw error?
            return
        }
        self.readBuffer.append(data)

        guard data.last == ControlCode.finish.rawValue else {
            // Do nothing, keep reading, keep walking
            return
        }
        guard let opcode = self.readBuffer.first else {
            // TODO: throw error...?
            return
        }
        switch opcode {
        case Opcode.text.rawValue:
            self.onTextFrame(trimmedFrame())
        case Opcode.binary.rawValue:
            self.onBinaryFrame(trimmedFrame())
        default:
            // throw error, undefined
            break
        }
        initializeFrame()
    }

    private func trimmedFrame() -> Data {
        self.inputFrame = self.readBuffer.dropFirst()
        self.inputFrame = self.inputFrame.dropFirst()
        self.inputFrame = self.inputFrame.dropLast()
        return self.inputFrame
    }

    private func initializeFrame() {
        self.readBuffer = Data()
        self.inputFrame = Data()
    }
}
