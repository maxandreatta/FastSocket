//
//  FastSocketTests.swift
//  FastSocketTests
//
//  Created by Vinzenz Weist on 02.04.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//

import XCTest
@testable import FastSocket

class FastSocketTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let exp = expectation(description: "Blub")
        let buffer = Data(count: 2000000)
        var core = Array<FastSocket>()
        var datacount = 0
        for i in 0...9 {
            core.append(FastSocket(host: "socket.weist.it", port: 3333))
            core[i].on.ready = {
                core[i].send(data: buffer)
            }
            core[i].on.text = { text in
                print("RECEIVED FROM: \(i) THIS COUNT: \(text)")
            }
            core[i].on.binary = { data in
                print("RECEIVED FROM: \(i) THIS COUNT: \(data.count)")
                //core.send(data: buffer)
            }
            core[i].on.writtenData = { count in
                datacount += count
                print(datacount)
            }
            core[i].connect()
        }
        wait(for: [exp], timeout: 100.0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
