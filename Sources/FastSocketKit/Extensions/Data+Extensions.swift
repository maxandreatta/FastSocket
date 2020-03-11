//
//  Data+Extensions.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 11.03.20.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import CryptoKit
import Foundation

extension Data: Message {
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
        if size <= Constant.maximumLength {
            size = Constant.maximumLength
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
    /// func to extract integers from data as big endian
    var integer: UInt32 {
        guard !self.isEmpty else { return .zero }
        return UInt32(bigEndian: withUnsafeBytes { bytes in
            bytes.load(as: UInt32.self)
        })
    }
}
