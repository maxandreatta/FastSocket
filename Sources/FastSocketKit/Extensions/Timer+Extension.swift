//
//  Timer+Extension.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 24.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation

// internal extensions
internal extension Timer {
    /// Creates and returns a DispatchSourceTimer
    /// - parameters:
    ///     - interval: TimerInterval in Seconds
    ///     - withRepeat: true if you want to repeat, false for only call it once
    ///     - block: closure
    static func interval(interval: TimeInterval, withRepeat: Bool = false, block: @escaping () -> Void) -> DispatchSourceTimer {
        let dispatchTimer = DispatchSource.makeTimerSource(flags: .strict, queue: DispatchQueue(label: Constant.prefix.unique))
        dispatchTimer.setEventHandler(handler: block)
        switch withRepeat {
        case true:
            dispatchTimer.schedule(deadline: .now(), repeating: interval)
        case false:
            dispatchTimer.schedule(deadline: .now() + interval, repeating: .never)
        }
        dispatchTimer.resume()
        return dispatchTimer
    }
}
