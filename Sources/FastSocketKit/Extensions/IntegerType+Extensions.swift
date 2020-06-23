//
//  Int+Extensions.swift
//  FastSocketKit
//
//  Created by Vinzenz Weist on 10.03.20.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
import Network

// internal extensions
internal extension FixedWidthInteger {
    /// first represents the static 1 identify element
    static var one: Int { 1 }
    /// convert an integer value with BigEndianUint64
    /// to an Data array
    var data: Data {
        withUnsafeBytes(of: self.bigEndian) { bytes in Data(bytes) }
    }
    /// penultimate represents the -1 element of an index
    /// this should only be used on index based enumerations
    /// cannot be applied on negativ values
    var penultimate: Int {
        guard self > .zero else { return Int(self) }
        return Int(self) - .one
    }
}
