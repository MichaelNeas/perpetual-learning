//
//  StarscreamSocket.swift
//  AllTheNetworks
//
//  Created by Michael Neas on 10/1/19.
//  Copyright © 2019 Neas Lease. All rights reserved.
//

import Foundation
import Starscream

class StarscreamSocket: WebSocketDelegate {

    var socket: WebSocket
    var components: URLComponents!
    
    init(url: URL) {
        components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        socket = WebSocket(url: components!.url!)
        socket.delegate = self
        socket.connect()
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let error = error {
            print("Error disconnecting \(error)")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Text Message \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Data Message \(String(decoding: data, as: UTF8.self))")
    }
    
    func send(text: String) {
        socket.write(string: text)
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
}
