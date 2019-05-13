//
//  NetworkTransfer.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 25.03.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
// swiftlint:disable closure_body_length multiline_arguments
import Foundation
import Network
/// NetworkTransfer is a raw TCP transfer
/// it uses the Network.framework. This is
/// the `Engine` of the FastSocket Protocol.
/// It allows to enter directly the TCP Options
internal class NetworkTransfer: TransferProtocol {
    internal var on = TransferClosures()
    private var connection: NWConnection?
    private var monitor = NWPathMonitor()
    private var transferParameters: TransferParameters
    private var connectionState: NWConnection.State?
    private var host: String
    private var port: UInt16
    private var queue: DispatchQueue
    private var type: TransferType
    private var isRunning: Bool = false
    private var isLocked: Bool = false
    private var allowUntrusted: Bool = false
    /// create a instance of NetworkTransfer
    /// - parameters:
    ///     - host: a server endpoint to connect, e.g.: "example.com"
    ///     - port: the port to connect, e.g.: 8000
    ///     - type: the transfer type (.tcp or .tls)
    ///     - allowUntrusted: if .tls connection are set, then allow untrusted certs
    ///     - transferParameters: TransferParameters `optional`
    ///     - queue: Dispatch Qeue `optional`
    required init(host: String, port: UInt16, type: TransferType = .tcp, allowUntrusted: Bool = false, transferParameters: TransferParameters = TransferParameters(), queue: DispatchQueue = DispatchQueue(label: "\(Constant.prefixNetwork)\(UUID().uuidString)", qos: .userInitiated)) {
        self.host = host
        self.port = port
        self.type = type
        self.allowUntrusted = allowUntrusted
        self.transferParameters = transferParameters
        self.queue = queue
    }
    /// connect to a host
    /// prevent reconnecting after a connection
    /// was successfully established
    internal func connect() {
        guard !self.isRunning else {
            return
        }
        self.connection = NWConnection(host: NWEndpoint.Host(self.host), port: NWEndpoint.Port(rawValue: self.port)!, using: self.parameters)
        self.isRunning = true
        self.connectionStateHandler()
        self.networkPathMonitor()
        self.readLoop()
        guard let connection = self.connection else {
            return
        }
        connection.start(queue: self.queue)
    }
    /// disconnect from host and
    /// cleanup the connection
    internal func disconnect() {
        self.clean()
    }
    /// write data async on tcp socket
    /// slices big data into chunks and send it stacked
    /// - parameters:
    ///     - data: the data which should be written on the socket
    internal func send(data: Data) {
        guard let connection = self.connection else {
            return
        }
        connection.batch { [weak self] in
            guard let self = self else {
                return
            }
            // this code prevent from multiple send of data at once
            // this feature is now possible, but in release versions it will be blocked for now
            // later we will allow this after loooooooooot of testing
            #if !DEBUG
            guard !self.isLocked else {
                self.on.error(FastSocketError.writeBeforeClear)
                return
            }
            #endif
            guard self.connectionState == .ready else {
                self.on.error(FastSocketError.sendToEarly)
                return
            }
            self.isLocked = true
            let queued = data.chunk(by: Constant.maximumLength)
            guard !queued.isEmpty else {
                return
            }
            var itterator = queued.enumerated().makeIterator()
            while let (i, data) = itterator.next() {
                connection.send(content: Data(data), completion: .contentProcessed({ error in
                    if let error = error {
                        guard error != NWError.posix(.ECANCELED) else {
                            // cancel error can be ignored
                            return
                        }
                        self.on.error(error)
                        return
                    }
                    self.on.dataWritten(data.count)
                    if i == queued.endIndex - 1 {
                        self.isLocked = false
                    }
                }))
            }
        }
    }
}

private extension NetworkTransfer {
    /// check connection state
    private func connectionStateHandler() {
        guard let connection = self.connection else {
            return
        }
        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else {
                return
            }
            self.connectionState = state
            switch state {
            case .ready:
                self.on.ready()

            case .waiting(let error):
                self.on.error(error)

            case .failed(let error):
                self.on.error(error)

            case .cancelled:
                self.on.close()

            default:
                break
            }
        }
    }
    /// cleanup a connection
    private func clean() {
        self.isRunning = false
        guard let connection = self.connection else {
            return
        }
        connection.cancel()
    }
    /// a network path monitor
    /// used to detect if network is unrechable
    private func networkPathMonitor() {
        self.monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else {
                return
            }
            guard path.status == .unsatisfied else {
                return
            }
            self.clean()
            self.on.error(FastSocketError.networkUnreachable)
        }
        self.monitor.start(queue: DispatchQueue(label: "\(Constant.prefixNetwork)\(UUID().uuidString)", qos: .userInitiated))
    }
    /// readloop for the tcp socket incoming data
    private func readLoop() {
        guard let connection = self.connection else {
            return
        }
        connection.batch { [weak self] in
            guard let self = self else {
                return
            }
            guard self.isRunning else {
                return
            }
            connection.receive(minimumIncompleteLength: Constant.minimumIncompleteLength, maximumLength: Constant.maximumLength) { [weak self] data, _, isComplete, error in
                guard let self = self else {
                    return
                }
                if let error = error {
                    guard error != NWError.posix(.ECANCELED) else {
                        // cancel error can be ignored
                        return
                    }
                    self.on.error(error)
                    return
                }
                if let data = data {
                    self.on.data(data)
                    self.on.dataRead(data.count)
                }
                switch isComplete {
                case true:
                    self.clean()
                    self.on.close()

                case false:
                    self.readLoop()
                }
            }
        }
    }
}

private extension NetworkTransfer {
    /// computed property to create the right transfer type
    /// and mapps the allowed parameters to the NWParameters
    /// - returns: NWParameters object
    var parameters: NWParameters {
        var param = NWParameters()
        switch self.type {
        case .tcp:
            param = NWParameters(tls: nil)

        case .tls:
            param = NWParameters(tls: self.options)
        }
        param.acceptLocalOnly = self.transferParameters.acceptLocalOnly
        param.allowFastOpen = self.transferParameters.allowFastOpen
        param.preferNoProxies = self.transferParameters.preferNoProxies
        param.prohibitedInterfaceTypes = self.transferParameters.prohibitedInterfaceTypes
        param.prohibitExpensivePaths = self.transferParameters.prohibitExpensivePaths
        param.requiredInterfaceType = self.transferParameters.requiredInterfaceType
        param.multipathServiceType = self.transferParameters.multipathServiceType
        param.serviceClass = self.transferParameters.serviceClass
        return param
    }
    /// computed property to overwrite standard
    /// tls options to give the ability to allow untrusted certs
    /// - returns: NWProtocolTLS.Options object
    var options: NWProtocolTLS.Options {
        let options = NWProtocolTLS.Options()
        sec_protocol_options_set_verify_block(options.securityProtocolOptions, { _, sec_trust, sec_protocol_verify_complete in
            let trust = sec_trust_copy_ref(sec_trust).takeRetainedValue()
            var error: CFError?
            switch SecTrustEvaluateWithError(trust, &error) {
            case true:
                sec_protocol_verify_complete(true)

            case false:
                switch self.allowUntrusted {
                case true:
                    sec_protocol_verify_complete(true)

                case false:
                    sec_protocol_verify_complete(false)
                }
            }
        }, self.queue)
        return options
    }
}
