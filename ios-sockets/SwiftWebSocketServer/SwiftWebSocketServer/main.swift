//
//  main.swift
//  SwiftWebSocketServer
//
//  Created by Michael Neas on 11/30/19.
//  Copyright © 2019 Neas Lease. All rights reserved.
//

import Foundation

var isServer = false

func initServer(port: UInt16) {
    let server = SwiftWebSocketServer(port: port)
    try! server.start()
}

if let port = UInt16(CommandLine.arguments[1]) {
    initServer(port: port)
} else {
    print("Error invalid port")
}

RunLoop.current.run()
