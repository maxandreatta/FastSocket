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
    private var socket = Octanium(host: "116.203.236.97", port: 7878)
    private var buffer = "1000"
    private var inputBytes = 0
    private var outputBytes = 0
    private var messages = 0
    private var index = 0
    private let timeout = 15.0
    private let sendValue = 100
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

extension FastSocketTestSendMulti: OctaniumDelegate {
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
            guard self.index < self.sendValue else { return }
            send()
        }
        
        if cases == .data {
            func send() {
                socket.send(message: Data(count: Int(buffer)!)) { [weak self] in
                    guard let self = self else { return }
                    if self.index != self.sendValue {
                        send()
                    }
                    self.index += 1
                }
            }
            guard self.index < self.sendValue else { return }
            send()
        }
    }
    
    internal func didGetClose() {
        debugPrint("connection closed")
    }
    
    internal func didGetMessage(_ message: Message) {
        if messages == sendValue {
            debugPrint("RECEIVED THIS COUNT: \(message)")
            debugPrint("Responded Times: \(messages)")
            XCTAssertEqual(messages, sendValue)
            exp?.fulfill()
        }
        messages += 1
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
