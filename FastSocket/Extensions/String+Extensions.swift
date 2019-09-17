//
//  String+Extensions.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 03.05.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
extension String: MessageProtocol {
    // conformance to send protocol
}

extension String {
    /// returns the utf8 representation of a string
    var utf8: Data {
        guard let data = self.data(using: .utf8) else {
            return Data()
        }
        return data
    }
}
