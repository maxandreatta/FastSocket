//
//  Closures.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

internal struct FrameClosures {
    internal var dataFrame: CallbackData = { _ in }
    internal var stringFrame: CallbackData = { _ in }
}

internal struct TransferClosures {
    internal var ready: Callback = { }
    internal var close: Callback = { }
    internal var data: CallbackData = { data in }
    internal var error: CallbackError = { error in }
    internal var dataInput: CallbackInt = { bytes in }
    internal var dataOutput: CallbackInt = { bytes in }
}

public struct FastSocketClosures {
    public var ready: Callback = { }
    public var close: Callback = { }
    public var string: CallbackString = { string in }
    public var data: CallbackData = { data in }
    public var error: CallbackError = { error in }
    public var dataRead: CallbackInt = { bytes in }
    public var dataWritten: CallbackInt = { bytes in }
}
