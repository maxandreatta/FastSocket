//
//  FastSocketDelegate.swift
//  FastSocketKit
//
//  Created by Vinzenz Weist on 03.02.21.
//

import Foundation

public protocol FastSocketDelegate: AnyObject {
    func didGetReady()
    func didGetClose()
    func didGetMessage(_ message: Message)
    func didGetBytes(_ bytes: Bytes)
    func didGetError(_ error: Error?)
}
