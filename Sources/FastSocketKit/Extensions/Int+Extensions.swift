//
//  Int+Extensions.swift
//  FastSocketKit
//
//  Created by Vinzenz Weist on 10.03.20.
//

import Foundation
// internal extensions
internal extension Int {
    /// penultimate represents the -1 element of an index
    /// this should only be used on index based enumerations
    var penultimate: Int { self - 1 }
    /// first represents the 1 element of an index
    /// this should only be used on index based enumerations
    static var first: Int { 1 }
}
