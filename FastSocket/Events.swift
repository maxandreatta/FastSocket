//
//  Events.swift
//  CustomTCP
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import Foundation

internal struct NetworkStreamEvents {
    internal var ready: () -> Void = { }
    internal var close: () -> Void = { }
    internal var data: (Data) -> Void = { data in }
    internal var error: (Error?) -> Void = { error in }
    internal var inputData: (Int) -> Void = { bytes in }
    internal var outputData: (Int) -> Void = { bytes in }
}

public struct FastSocketEvents {
    public var ready: () -> Void = { }
    public var close: () -> Void = { }
    public var text: (String) -> Void = { text in }
    public var binary: (Data) -> Void = { data in }
    public var error: (Error?) -> Void = { error in }
    public var receivedData: (Int) -> Void = { bytes in }
    public var writtenData: (Int) -> Void = { bytes in }
}
