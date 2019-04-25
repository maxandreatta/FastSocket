//
//  Events.swift
//  CustomTCP
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation

internal struct NetworkStreamEvents {
    internal var ready: Callback = { }
    internal var close: Callback = { }
    internal var data: CallbackData = { data in }
    internal var error: CallbackError = { error in }
    internal var dataInput: CallbackInt = { bytes in }
    internal var dataOutput: CallbackInt = { bytes in }
}

public struct FastSocketEvents {
    public var ready: Callback = { }
    public var close: Callback = { }
    public var text: CallbackString = { text in }
    public var binary: CallbackData = { data in }
    public var error: CallbackError = { error in }
    public var dataRead: CallbackInt = { bytes in }
    public var dataWritten: CallbackInt = { bytes in }
}
