<div align="center">
    <h1>
        <br>
            <a href="https://github.com/Vinz1911/FastSocket"><img src="https://github.com/Vinz1911/FastSocket/blob/master/.fastsocket.svg" alt="FastSocket" width="600"></a>
        <br>
            FastSocket
        <br>
    </h1>
</div>

`FastSocket` is a proprietary bi-directional message based communication protocol on top of TCP (optionally over other layers in the future). The idea behind this project was, to create a TCP communication like the [WebSocket Protocol](https://tools.ietf.org/html/rfc6455) with less overhead and the ability to track every 8192 bytes read or written on the socket without waiting for the whole message to be transmitted. This allows it to use it as **protocol for speed tests** for measuring the TCP throughput performance. Our server-sided implementation is written in [golang](https://golang.org/) and it's optimized for maximum speed and performance.

The server sided implementation of the FastSocket Protocol can be found here: [FastSocketServer](https://github.com/Vinz1911/FastSocketServer). The repository also contains a demo implementation of the server code with a simple speedtest.

## Features:
- [X] send and receive text and data messages
- [X] async, non-blocking & very fast
- [X] threading is handled by the framework itself
- [X] track send & received bytes
- [X] allows you to chose the network interface!
- [X] zer0 dependencies, native swift implementation with Network.framework
- [X] custom error management
- [X] all errors are routed through the error closure
- [X] maximum frame size 16777216 bytes (with overhead)
- [X] content length base framing instead of fin byte termination
- [X] send/receive multiple messages at once
- [X] TLS support
- [X] XCFramework support
- [X] Swift Packages support

## License:
[![License](https://img.shields.io/badge/license-GPLv3-blue.svg?longCache=true&style=flat)](https://github.com/Vinz1911/FastSocket/blob/master/LICENSE)

## Swift Version:
[![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg?logo=swift&style=flat)](https://swift.org) [![Swift 5.1](https://img.shields.io/badge/SPM-Support-orange.svg?logo=swift&style=flat)](https://swift.org)

## Build Status:
|  Branch |                                                                                     Build Status                                                                                    |                                                                                                    Coverage                                                                                                   |                                                                                              Maintainability                                                                                              |
|:-------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|  master |   [![Travis Master](https://img.shields.io/travis/Vinz1911/FastSocket/master.svg?label=master&logo=travis&style=flat)](https://travis-ci.org/Vinz1911/FastSocket/builds)   | [![Code Climate Coverage](https://img.shields.io/codeclimate/coverage/Vinz1911/FastSocket.svg?color=brightgreen&logo=code%20climate&style=flat)](https://codeclimate.com/github/Vinz1911/FastSocket) | [![Code Climate Maintainability](https://img.shields.io/codeclimate/maintainability/Vinz1911/FastSocket.svg?logo=Code%20Climate&style=flat)](https://codeclimate.com/github/Vinz1911/FastSocket) |
| develop |  [![Travis Develop](https://img.shields.io/travis/Vinz1911/FastSocket/develop.svg?label=develop&logo=travis&style=flat)](https://travis-ci.org/Vinz1911/FastSocket/builds) |                                                                                                                                                                                                               |                                                                                                                                                                                                           |

## Installation:
### XCFramework
Download the latest Framework Version from the [Release](https://github.com/Vinz1911/FastSocket/releases) section. 
Copy the FastSocket.xcframework to your `Frameworks and Libraries` section.

### Swift Packages
Full support for [SwiftPackageManager](https://developer.apple.com/documentation/swift_packages). Just add the repo to your project in the project settings under Swift Packages.

## Import:
```swift
// import the Framework
import FastSocketKit

// normal init with TCP (unsecure) transfer type
let socket = FastSocket(host: "example.com", port: 8080)

// use TLS (secure) instead of TCP (unsecure)
// NOTE: The backend must be setted up with support for TLS otherwise
// this will not work and end up in an TLS Error
let socket = FastSocket(host: "example.com", port: 8000)
socket.parameters = .tls

...

socket.connect()
```

## Closures:
```swift
socket.on.ready = {
    // this is called after the connection
    // was successfully established and is ready
}
socket.on.message = { message in
    // this is called everytime
    // a message was received
}
socket.on.bytes = { bytes in
    // this is called everytime bytes are readed 
    // or written from/on the socket
}
socket.on.close = {
    // this is called after
    // the socket was closed
}
socket.on.error = { error in
    // this is called everytime
    // an error appeared
}
```

## Cast Messages:
```swift
socket.on.message = { message in
    // it's only possible to cast messages
    // as Data or as String
    if case let message as Data = message {
        // cast message as data
        print("Data count: \(message.count)")
    }
    if case let message as String = message {
        // cast message as string
        print("Message: \(message)")
    }
}
```

## Read Bytes Count:
```swift
socket.on.bytes = { bytes in
    // input bytes are the ones, which are
    // readed from the socket, this function
    // returns the byte count
    if case .input(let count) = bytes {
        print("Bytes count: \(count)")
    }
    // output bytes are the ones, which are
    // written on the socket, this function
    // returns the byte count
    if case .output(let count) = bytes {
        print("Bytes count: \(count)")
    }
}
```

## Connect & Disconnect:
```swift
// try to connect to the host
// timeout after 3.0 seconds
socket.connect()

// closes the connection
socket.disconnect()
```

## Send Messages:
```swift
// the send func is a generic func
// it allows to send `String` and `Data`
// generic T don't accept other data types
socket.send(message: T)

// the send function also has an optional completion block
// this is only possible if its not referenced by the protocol
// if it's referenced by the protocol, you need to implement 
// the completion block, because there are no default values in protocols
socket.send(message: T) {
    // do anything if data is successfully
    // processed by the network stack
}

// NOTE: it's possible to send multiple messages at once
// we discovered a problem if you doing this in a loop,
// this can cause a overflow problem in network.framework's send process
// and the entire process get's stucked. So we implemented some technics to prevent this
// you can now send in a loop but this will end up in lost data because we give the process
// the time he needs to fully process the data into the network stack. If you want to send multiple
// messages at once you should do this inside the completion block. This guarantees the following:
// - 1. The entire data will be transmit, no data will be skipped
// - 2. The process performs with the maximum performance that network.framework can provide
// - 3. The performance scales linear, so it's no problem to send 1M+ messages after each other
// EXAMPLE:

// counter
var count: Int = 0

// send the message
func send() {
    socket.send(message: "Hello World!") {
        guard count <= 1_000_000 else { return }
        count += 1
        // recursive function call of the send method
        send()
    }
}
```

## Additional Parameters:
```swift
// FastSocket was build in top of Apple's Network.framework
// that allows us to use lot of TCP features like fast open or
// to select the network interface type

// import the Framework
import FastSocketKit

// init FastSocket object
let socket = FastSocket(host: "example.com", port: 8080)

// ...

// set the traffics service class
socket.parameters.serviceClass = .interactiveVoice

// select the interface type
// if it's not available, it will cancel with an error
socket.parameters.requiredInterfaceType = .cellular

// also the entire parameters object can be overwritten
socket.parameters = NWParamters()
```

## Author:
 - 👨🏼‍💻 [Vinzenz Weist](https://github.com/Vinz1911)
This is my heart project, it's made with a lot of love and dedication ❤️

## Supporter:
- 👨🏽‍💻 [Juan Romero](https://github.com/rukano)
