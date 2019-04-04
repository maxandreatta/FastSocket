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

    func testDownload() {
        let exp = expectation(description: "Blub")
        let buffer = Data(count: 100000)
        var core = Array<FastSocket>()
        var datacount = 0
        for i in 0...9 {
            core.append(FastSocket(host: "socket.weist.it", port: 3333))
            core[i].on.ready = {
                //core[i].send(data: buffer)
                core[i].send(text: "1000000")
            }
            core[i].on.text = { text in
                print("RECEIVED FROM: \(i) THIS COUNT: \(text)")
                //core[i].send(data: buffer)
            }
            core[i].on.binary = { data in
                print("RECEIVED FROM: \(i) THIS COUNT: \(data.count)")
                core[i].send(text: "1000000")
            }
//            core[i].on.dataWritten = { count in
//                datacount += count
//                print(datacount)
//            }
            core[i].on.dataRead = { count in
                datacount += count
                print(datacount)
            }

            core[i].connect()
        }
        wait(for: [exp], timeout: 100.0)
    }
    
}
