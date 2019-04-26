//
//  FastSocketTests.swift
//  FastSocketTests
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import XCTest
import Network
@testable import FastSocket

class FastSocketTests: XCTestCase {

    func testDownload() {
        let exp = expectation(description: "Wait for speed test to finish")
        let buffer = "500000"
        let socket: FastSocket = self.createSocket()
        var datacount = 0
        socket.on.ready = {
            socket.send(string: buffer)
        }
        socket.on.data = { data in
            print("RECEIVED THIS COUNT: \(data.count)")
            exp.fulfill()
        }
        socket.on.dataRead = { count in
            datacount += count
            print(datacount)
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: 10.0)
    }

    func testUpload() {
        let exp = expectation(description: "Wait for speed test to finish")
        let buffer = Data(count: 500000)
        let socket: FastSocket = self.createSocket()
        var datacount = 0
        socket.on.ready = {
            socket.send(data: buffer)
        }
        socket.on.string = { text in
            print("RECEIVED THIS COUNT: \(text)")
            exp.fulfill()
        }
        socket.on.dataWritten = { count in
            datacount += count
            print(datacount)
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: 10.0)
    }
    
    func testClose() {
        let exp = expectation(description: "Wait for connection close")
        let socket = self.createSocket()
        socket.on.ready = {
            print("connection established")
            socket.disconnect()
        }
        socket.on.close = {
            print("connection closed")
            exp.fulfill()
        }
        socket.on.error = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: 5.0)
    }
}

extension FastSocketTests {
    func createSocket() -> FastSocket {
        let socket = FastSocket(host: "socket.weist.it", port: 3333)
        socket.parameters.serviceClass = .interactiveVoice
        return socket
    }
}
