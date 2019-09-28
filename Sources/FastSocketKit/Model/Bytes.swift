//
//  Bytes.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 15.05.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
/// generic result type for transmitted bytes
public enum Bytes {
    /// input bytes are the bytes
    /// which are *readed from the socket*
    case input(Int)
    /// output bytes are the bytes
    /// which are *written on the socket*
    case output(Int)
}
