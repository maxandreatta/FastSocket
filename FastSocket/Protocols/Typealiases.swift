//
//  Typealiases.swift
//  FastSocket
//
//  Created by Romero, Juan, SEVEN PRINCIPLES on 04.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
/// typealias for a normal closure
public typealias Callback = () -> Void
/// typealias for a closure which returns some data
public typealias CallbackData = (Data) -> Void
/// typealias for a closure which return an optional error
public typealias CallbackError = (Error?) -> Void
/// typealias for the message closure
public typealias CallbackMessage = (MessageTypeProtocol) -> Void
/// typealias for a closure which returns the written and readed bytes count
public typealias CallbackBytes = (ByteCountResult<Int>) -> Void
