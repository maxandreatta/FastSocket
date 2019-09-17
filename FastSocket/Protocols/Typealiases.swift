//
//  Typealiases.swift
//  FastSocket
//
//  Created by Romero, Juan, SEVEN PRINCIPLES on 04.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
/// typealias for a normal closure
public typealias FastSocketCallback = () -> Void
/// typealias for a closure which returns some data
public typealias FastSocketCallbackData = (Data) -> Void
/// typealias for a closure which return an optional error
public typealias FastSocketCallbackError = (Error?) -> Void
/// typealias for the message closure
public typealias FastSocketCallbackMessage = (MessageProtocol) -> Void
/// typealias for a closure which returns the written and readed bytes count
public typealias FastSocketCallbackBytes = (ByteCountResult) -> Void
