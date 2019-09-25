//
//  Data+Extensions.swift
//  FastSocket
//
//  Created by Romero, Juan, SEVEN PRINCIPLES on 04.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import CryptoKit
import Foundation

extension Data: MessageProtocol {
    // conformance to send protocol
}
// internal extensions
internal extension Data {
    /// helper for frame
    /// trims a frame to it's raw content
    var trim: Data? {
        guard self.count >= Constant.overheadSize else { return nil }
        return Data(self[Constant.overheadSize...])
    }
    /// slice data into chunks, dynamically based
    /// on maximum iterations for sending, minimum size
    /// is 8192 per sliceBytes
    var chunk: [Data] {
        var size = self.count / Constant.iterations
        if size <= Constant.minimumChunkSize {
            size = Constant.minimumChunkSize
        }
        return stride(from: .zero, to: self.count, by: size).map { count in
            Data(self[count..<Swift.min(count + size, self.count)])
        }
    }
    /// generates a sha256 hash value
    /// from .utf8 data and returns the hash as data
    var sha256: Data {
       Data(SHA256.hash(data: self))
    }
    /// generic func to extract integers from data as big endian
    var integer: Int {
        guard !self.isEmpty else { return .zero }
        return Int(bigEndian: withUnsafeBytes { bytes in
            bytes.load(as: Int.self)
        })
    }
}
