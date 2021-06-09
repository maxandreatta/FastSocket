import Network
import XCTest
@testable import FastSocketKit

class FastSocketKitTests: XCTestCase {
    /// the host address
    var host: String = "localhost"
    /// the port
    var port: UInt16 = 7878
    /// timeout for all tests
    var timeout: TimeInterval = 15.0

    /// a test for sending strings and responding data from the backend
    /// this is the definition of a download speedtest
    func testStringSendAndRespond() {
        let exp = expectation(description: "Wait for test to finish")
        let buffer = "50000"
        var datacount = 0
        let socket = NetworkConnection(host: host, port: port)
        socket.state = { state in
            switch state {
            case .didGetReady:
                socket.send(message: buffer)
            case .didGetCancelled:
                debugPrint("connection closed")
            case .didGetError(let error):
                guard let error = error else { return }
                XCTFail("Failed with Error: \(error)")
            case .didGetMessage(let message):
                if case let message as Data = message {
                    XCTAssertEqual(message.count, Int(buffer))
                    exp.fulfill()
                }
            case .didGetBytes(let bytes):                
                guard let byte = bytes.input else { return }
                datacount += byte
                debugPrint("Data Count: \(datacount)")
            }
        }
        socket.openConnection()
        wait(for: [exp], timeout: timeout)
    }
    
    
    /// a test for sending data and responding strings from the backend
    /// this is the definition of a upload speedtest
    func testDataSendAndRespond() {
        let exp = expectation(description: "Wait for test to finish")
        let buffer = Data(count: 50000)
        var datacount = 0
        let socket = NetworkConnection(host: host, port: port)
        socket.state = { state in
            switch state {
            case .didGetReady:
                socket.send(message: buffer)
            case .didGetCancelled:
                debugPrint("connection closed")
            case .didGetError(let error):
                guard let error = error else { return }
                XCTFail("Failed with Error: \(error)")
            case .didGetMessage(let message):
                if case let message as String = message {
                    XCTAssertEqual(buffer.count, Int(message))
                    exp.fulfill()
                }
            case .didGetBytes(let bytes):
                guard let byte = bytes.output else { return }
                datacount += byte
                debugPrint("Data Count: \(datacount)")
            }
        }
        socket.openConnection()
        wait(for: [exp], timeout: timeout)
    }
    /// a test for multiple sending data to the backend and receive
    /// multiple strings from the backend
    func testMultipleSendDataAndReceiveString() {
        let exp = expectation(description: "Wait for test to finish")
        let buffer = Data(count: 1024)
        var messages = 0
        let sendValue = 100
        var index = 0
        let socket = NetworkConnection(host: host, port: port)
        socket.state = { state in
            switch state {
            case .didGetReady:
                func send() {
                    socket.send(message: buffer) {
                        if index != sendValue {
                            send()
                        }
                        index += 1
                    }
                }
                send()
            case .didGetCancelled:
                debugPrint("connection closed")
            case .didGetError(let error):
                guard let error = error else { return }
                XCTFail("Failed with Error: \(error)")
            case .didGetMessage(let message):
                if case let message as String = message {
                    if messages == sendValue {
                        debugPrint("RECEIVED THIS COUNT: \(message)")
                        debugPrint("Responded Times: \(messages)")
                        exp.fulfill()
                    }
                    messages += 1
                }
            default: break
            }
        }
        socket.openConnection()
        wait(for: [exp], timeout: timeout)
    }
    /// a test for multiple sending strings to the backend and receive
    /// multiple data from the backend
    func testMultipleSendStringAndReceiveData() {
        let exp = expectation(description: "Wait for test to finish")
        let buffer = "1024"
        var messages = 0
        let sendValue = 1000
        var index = 0
        let socket = NetworkConnection(host: host, port: port)
        socket.state = { state in
            switch state {
            case .didGetReady:
                func send() {
                    socket.send(message: buffer) {
                        if index != sendValue {
                            send()
                        }
                        index += 1
                    }
                }
                send()
            case .didGetCancelled:
                debugPrint("connection closed")
            case .didGetError(let error):
                guard let error = error else { return }
                XCTFail("Failed with Error: \(error)")
            case .didGetMessage(let message):
                if case let message as Data = message {
                    if messages == sendValue {
                        debugPrint("RECEIVED THIS COUNT: \(message.count)")
                        debugPrint("Responded Times: \(messages)")
                        exp.fulfill()
                    }
                    messages += 1
                }
            default: break
            }
        }
        socket.openConnection()
        wait(for: [exp], timeout: timeout)
    }
    /*
    /// a test to look if the client can close a connection
    func testClose() {
        let exp = expectation(description: "Wait for connection close")
        let socket = NetworkConnection(host: host, port: port)
        socket.callback.didGetReady = {
            socket.disconnect()
        }
        socket.callback.didGetClose = {
            debugPrint("Connection Closed!")
            exp.fulfill()
        }
        socket.callback.didGetError = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        socket.connect()
        wait(for: [exp], timeout: timeout)
    }
    /// a test to measure how long the handshake takes
    /// and the connection is ready to be used
    func testPerformance() {
        let exp = expectation(description: "Wait for connection close")
        let socket = NetworkKit(host: host, port: port)
        var startTime = Date().timeIntervalSince1970
        socket.callback.didGetReady = {
            debugPrint(Date().timeIntervalSince1970 - startTime)
            exp.fulfill()
        }
        socket.callback.didGetClose = {
            debugPrint("Connection Closed!")
        }
        socket.callback.didGetError = { error in
            guard let error = error else { return }
            XCTFail("Failed with Error: \(error)")
        }
        startTime = Date().timeIntervalSince1970
        socket.connect()
        wait(for: [exp], timeout: timeout)
    }
    /// a test to look if the timeout stops trying to connect
    /// if the host doesnt respond
    func testTimeout() {
        let exp = expectation(description: "Wait for connection close")
        let socket = NetworkKit(host: "telekom.de", port: port)
        socket.callback.didGetError = { error in
            guard let error = error else { return }
            XCTAssertEqual(error as! OctaniumError, OctaniumError.timeoutError)
            exp.fulfill()
        }
        socket.connect()
        wait(for: [exp], timeout: timeout)
    }
    /// a test to look if the framework recognize empty host addresses
    func testFastSocketError() {
        let socket = NetworkKit(host: "", port: port)
        socket.callback.didGetError = { error in
            guard let error = error else { return }
            XCTAssertEqual(error as! OctaniumError, OctaniumError.emptyHost)
        }
        socket.connect()
    }
    /// a test to look if the framing recognize empty data
    func testFrameErrorZeroData() {
        let frame = NetworkFrame()
        let data = Data(count: 0)
        frame.parse(data: data) { _, error in
            if let error = error {
                XCTAssertEqual(error as! OctaniumError, OctaniumError.zeroData)
            }
        }
    }
    /// a test to look if the framing recognize a memory overflow
    func testFrameErrorOverflow() {
        let frame = PeerFrame()
        let data = Data(count: Constant.frameSize)
        _ = frame.create(message: data) { error in
            if let error = error {
                XCTAssertEqual(error as! OctaniumError, OctaniumError.writeBufferOverflow)
            }
        }
    }
    /// a test to look if the closures work
    func testClosureCall() {
        let closures = OctaniumCallback()
        closures.didGetReady()
        closures.didGetClose()
        closures.didGetMessage("")
        closures.didGetBytes(ClientBytes())
        closures.didGetError(OctaniumError.none)
    }
    /// a test to look if the framework recognize early send error
    /// that will be thrown if you try to send a string before a connection is established
    func testSendStringError() {
        let socket = NetworkKit(host: host, port: port)
        socket.callback.didGetError = { error in
            XCTAssertEqual(error as! OctaniumError, OctaniumError.sendToEarly)
        }
        socket.send(message: "")
    }
    /// a test to look if the framework recognize early send error
    /// that will be thrown if you try to send data before a connection is established
    func testSendDataError() {
        let socket = NetworkKit(host: host, port: port)
        socket.callback.didGetError = { error in
            XCTAssertEqual(error as! OctaniumError, OctaniumError.sendToEarly)
        }
        socket.send(message: Data())
    }
    /// a test to compare the errors description
    func testError() {
        XCTAssertEqual(OctaniumError.errorDomain, "de.NetworkKit.error")
        XCTAssertEqual(OctaniumError.none.errorUserInfo["NSLocalizedDescription"], "null")
        XCTAssertEqual(OctaniumError.handshakeInitializationFailed.errorUserInfo["NSLocalizedDescription"], "cannot create handshake data, please retry")
        XCTAssertEqual(OctaniumError.handshakeVerificationFailed.errorUserInfo["NSLocalizedDescription"], "handshake verification failed, hash values are different. this can happen if theres a proxy network between...")
        XCTAssertEqual(OctaniumError.emptyHost.errorUserInfo["NSLocalizedDescription"], "host address cannot be empty!")
        XCTAssertEqual(OctaniumError.zeroPort.errorUserInfo["NSLocalizedDescription"], "port cannot be zero!")
        XCTAssertEqual(OctaniumError.timeoutError.errorUserInfo["NSLocalizedDescription"], "connection timeout error")
        XCTAssertEqual(OctaniumError.networkUnreachable.errorUserInfo["NSLocalizedDescription"], "network is down or not reachable")
        XCTAssertEqual(OctaniumError.sendFailed.errorUserInfo["NSLocalizedDescription"], "send failure, data was not written")
        XCTAssertEqual(OctaniumError.sendToEarly.errorUserInfo["NSLocalizedDescription"], "socket is not ready, could not send")
        XCTAssertEqual(OctaniumError.socketClosed.errorUserInfo["NSLocalizedDescription"], "socket was closed")
        XCTAssertEqual(OctaniumError.socketUnexpectedClosed.errorUserInfo["NSLocalizedDescription"], "socket was unexpected closed")
        XCTAssertEqual(OctaniumError.writeBeforeClear.errorUserInfo["NSLocalizedDescription"], "previous data not finally written!, cannot write on socket")
        XCTAssertEqual(OctaniumError.parsingFailure.errorUserInfo["NSLocalizedDescription"], "message parsing error, no valid UTF-8")
        XCTAssertEqual(OctaniumError.zeroData.errorUserInfo["NSLocalizedDescription"], "data is empty cannot parse into message")
        XCTAssertEqual(OctaniumError.readBufferIssue.errorUserInfo["NSLocalizedDescription"], "readbuffer issue, is empty or wrong data")
        XCTAssertEqual(OctaniumError.unknownOpcode.errorUserInfo["NSLocalizedDescription"], "unknown opcode, cannot parse message")
        XCTAssertEqual(OctaniumError.readBufferOverflow.errorUserInfo["NSLocalizedDescription"], "readbuffer overflow!")
        XCTAssertEqual(OctaniumError.writeBufferOverflow.errorUserInfo["NSLocalizedDescription"], "writebuffer overflow!")
        XCTAssertEqual(OctaniumError.none.errorCode, 0)
    }
    /// a test to look if the dispatch timer works
    func testTimer() {
        let exp = expectation(description: "Timer")
        var timer: DispatchSourceTimer?
        timer = Timer.timeout(after: 1.0) {
            timer?.cancel()
            exp.fulfill()
        }
        wait(for: [exp], timeout: timeout)
    }
    /// measue parser performance
    func testMeasureParserPerformance() {
        let frame = PeerFrame()
        let data = Data(count: Constant.frameSize - 5)
        let message = frame.create(message: data) { error in
            if let error = error {
                print(error)
            }
        }
        measure {
            frame.parse(data: message) { message, error in }
        }
    }
    */
}

