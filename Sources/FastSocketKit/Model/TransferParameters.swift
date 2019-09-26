//
//  TransportParameter.swift
//  FastSocket
//
//  Created by Vinzenz Weist on 13.05.19.
//  Copyright © 2019 Vinzenz Weist. All rights reserved.
//
import Foundation
import Network
/// This is used to set some low level tcp parameters
/// for network interface and other stuff like fast open
public struct TransferParameters {
    /// Cause an NWListener to only advertise services on the local link,
    /// and only accept connections from the local link.
    public var acceptLocalOnly: Bool = false
    /// Use fast open for an outbound NWConnection, which may be done at any
    /// protocol level. Use of fast open requires that the caller send
    /// idempotent data on the connection before the connection may move
    /// into ready state. As a side effect, this may implicitly enable
    /// fast open for protocols in the stack, even if they did not have
    /// fast open explicitly enabled on them (such as the option to enable
    /// TCP Fast Open).
    public var allowFastOpen: Bool = false
    /// If true, a direct connection will be attempted first even if proxies are configured. If the direct connection
    /// fails, connecting through the proxies will still be attempted.
    public var preferNoProxies: Bool = false
    /// Define one or more interface types that a connection will not be allowed to use
    public var prohibitedInterfaceTypes: [NWInterface.InterfaceType] = []
    /// Disallow connection from using interfaces considered expensive
    public var prohibitExpensivePaths: Bool = false
    /// Require a connection to use a specific interface, or fail if not available
    public var requiredInterfaceType: NWInterface.InterfaceType = .other
    /// The ServiceClass represents the network queuing priority to use
    /// for traffic generated by a NWConnection.
    public var serviceClass: NWParameters.ServiceClass = .bestEffort
    /// Multipath services represent the modes of multipath usage that are
    /// allowed for connections.
    public var multipathServiceType: NWParameters.MultipathServiceType = .disabled
}