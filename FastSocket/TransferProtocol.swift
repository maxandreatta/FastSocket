//
//  TransferProtocol.swift
//  CustomTCP
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation

internal protocol TransferProtocol {
    var on: NetworkStreamEvents { get set }
    func connect()
    func disconnect()
    func send(data: Data)
}
