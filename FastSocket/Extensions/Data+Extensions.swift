//
//  Data+Extensions.swift
//  FastSocket
//
//  Created by Romero, Juan, SEVEN PRINCIPLES on 04.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import CommonCrypto
import Foundation

extension Data: MessageTypeProtocol {
    // conformance to send protocol
}
internal extension Data {
    /// generates a sha256 hash value
    /// from .utf8 data and returns the hash as data
    var sha256: Data {
        var hash = [UInt8](repeating: .zero, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
    /// slice data into chunks, dynamically based
    /// on maximum iterations for sending, minimum size
    /// is 8192 per sliceBytes
    func chunk(by iterations: Int) -> [Data] {
        var size = self.count / iterations
        if size <= 8192 {
            size = 8192
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
