//
//  FastSocketTestSendMulti.swift
//  FastSocketKitTests
//
//  Created by Vinzenz Weist on 03.02.21.
//

import Foundation

import Network
import XCTest
@testable import FastSocketKit

private enum TestCase {
    case string
    case data
}

class FastSocketTestSendMulti: XCTestCase {
    private var socket = FastSocket(host: "94.130.72.153", port: 7878)
    private var buffer = "50000"
    private var inputBytes = 0
    private var outputBytes = 0
    private var messages = 0
    private var index = 0
    private let timeout = 15.0
    private let sendValue = 1000
    private var cases: TestCase? = nil
    private var exp: XCTestExpectation?
    /// set up
    override func setUp() {
        super.setUp()
        socket.delegate = self
        exp = expectation(description: "wait for test to finish...")
    }
    /// run test
    func testString() {
        cases = .string
        socket.connect()
        wait(for: [exp!], timeout: timeout)
    }
    func testData() {
        cases = .data
        socket.connect()
        wait(for: [exp!], timeout: timeout)
    }
}

extension FastSocketTestSendMulti: FastSocketDelegate {
    internal func didGetReady() {
        if cases == .string {
            func send() {
                socket.send(message: buffer) { [weak self] in
                    guard let self = self else { return }
                    if self.index != self.sendValue {
                        send()
                    }
                    self.index += 1
                }
            }
            send()
        }
        if cases == .data {
            socket.send(message: Data(count: Int(buffer)!))
        }
    }
    
    internal func didGetClose() {
        debugPrint("connection closed")
    }
    
    internal func didGetMessage(_ message: Message) {
        if case let message as Data = message {
            XCTAssertEqual(message.count, Int(buffer))
            exp?.fulfill()
        }
        if case let message as String = message {
            XCTAssertEqual(message, buffer)
            exp?.fulfill()
        }
    }
    
    internal func didGetBytes(_ bytes: Bytes) {
        if let byte = bytes.input {
            inputBytes += byte
            debugPrint("input bytes:", inputBytes)
        }
        if let byte = bytes.output {
            outputBytes += byte
            debugPrint("output bytes:", outputBytes)
        }
    }
    
    internal func didGetError(_ error: Error?) {
        guard let error = error else { return }
        XCTFail("failed with error: \(error)")
    }
}
