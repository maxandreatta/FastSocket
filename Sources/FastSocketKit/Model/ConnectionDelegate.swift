//
//  ConnectionDelegate.swift
//  FastSocketKit
//
//  Created by Vinzenz Weist on 03.02.21.
//

import Foundation

internal protocol ConnectionDelegate: AnyObject {
    func didGetReady()
    func didGetClose()
    func didGetData(_ data: Data)
    func didGetBytes(_ bytes: Bytes)
    func didGetError(_ error: Error?)
}
