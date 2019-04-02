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
    internal var onBinaryFrame: (_ data: Data) -> () = { _ in }
    internal var onTextFrame: (_ data: Data) -> () = { _ in }
    internal var outputFrame: Data
    internal var inputFrame: Data
    internal var readBuffer: Data
    internal init() {
        self.inputFrame = Data()
        self.outputFrame = Data()
        self.readBuffer = Data()
    }
    internal func create(data: Data, opcode: Opcode) -> Data {
        self.outputFrame = Data()
        self.outputFrame.append(opcode.rawValue)
        self.outputFrame.append(ControlCode.continueByte.rawValue)
        self.outputFrame.append(data)
        self.outputFrame.append(ControlCode.finByte.rawValue)
        return self.outputFrame
    }
    
    internal func parse(data: Data) {
        guard data.count > 0 else { return }
        self.readBuffer.append(data)
        guard data[data.count - 1] == ControlCode.finByte.rawValue else { return }
        if self.readBuffer[0] == Opcode.text.rawValue {
            self.inputFrame = self.readBuffer.dropFirst()
            self.inputFrame = self.inputFrame.dropFirst()
            self.inputFrame = self.inputFrame.dropLast()
            self.onTextFrame(self.inputFrame)
        }
        if self.readBuffer[0] == Opcode.binary.rawValue {
            self.inputFrame = self.readBuffer.dropFirst()
            self.inputFrame = self.inputFrame.dropFirst()
            self.inputFrame = self.inputFrame.dropLast()
            self.onBinaryFrame(self.inputFrame)
        }
        self.readBuffer = Data()
        self.inputFrame = Data()
    }
}
