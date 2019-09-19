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
    /// generates a sha256 hash value
    /// from .utf8 data and returns the hash as data
    var sha256: Data {
        let digest = SHA256.hash(data: self)
        return Data(digest)
    }
    /// slice data into chunks, dynamically based
    /// on maximum iterations for sending, minimum size
    /// is 8192 per sliceBytes
    func chunk(by iterations: Int) -> [Data] {
        var size = self.count / iterations
        if size <= Constant.minimumChunkSize {
            size = Constant.minimumChunkSize
        }
        return stride(from: .zero, to: self.count, by: size).map { count in
            Data(self[count..<Swift.min(count + size, self.count)])
        }
    }
    /// generic func to extract integers from data as big endian
    func intValue<T: FixedWidthInteger>() -> T {
        guard !self.isEmpty else {
            return .zero
        }
        return T(bigEndian: withUnsafeBytes { bytes in
            bytes.load(as: T.self)
        })
    }
}
