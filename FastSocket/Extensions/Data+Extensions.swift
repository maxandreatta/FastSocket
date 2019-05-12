//
//  Data+Extensions.swift
//  FastSocket
//
//  Created by Romero, Juan, SEVEN PRINCIPLES on 04.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import CommonCrypto
import Foundation

extension Data: SendProtocol {
    // conformance to send protocol
}
internal extension Data {
    /// slice data into chunks:
    /// - parameters:
    ///     - size: size of the sliced chunks
    func chunk(by size: Int) -> [Data] {
        return stride(from: 0, to: self.count, by: size).map { count in
            Data(self[count..<Swift.min(count + size, self.count)])
        }
    }
    /// convert big endian to uint64
    func int() -> UInt64 {
        guard !self.isEmpty else {
            return 0
        }
        return UInt64(bigEndian: withUnsafeBytes { bytes in
            bytes.load(as: UInt64.self)
        })
    }
    /// generates a sha256 hash value
    /// from .utf8 data and returns the hash as data
    func SHA256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
}
