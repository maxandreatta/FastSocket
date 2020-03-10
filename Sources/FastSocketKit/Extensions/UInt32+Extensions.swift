//
//  UInt32+Extensions.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 09.05.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
// internal extensions
internal extension UInt32 {
    /// convert an integer value with BigEndianUint64
    /// to an Data array
    var data: Data {
        withUnsafeBytes(of: UInt32(bigEndian: self)) { bytes in
            Data(bytes)
        }
    }
    /// penultimate represents the -1 element of an index
    /// this should only be used on index based enumerations
    var penultimate: UInt32 { self - 1 }
}
