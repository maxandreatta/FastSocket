//
//  Reference.swift
//  CustomTCP
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation

enum ControlCode: UInt8 {
    case `continue` = 0x0
    case accept =   0xFE
    case finish = 0xFF
}

enum Opcode: UInt8 {
    case text =                 0x1
    case binary =               0x2
    // 3-7 reserved.
    case connectionClose =      0x8
}

extension Data {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
