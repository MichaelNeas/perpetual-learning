//
//  Model.swift
//  SocketTest
//
//  Created by Michael Neas on 10/4/19.
//  Copyright © 2019 Neas Lease. All rights reserved.
//

import Foundation
import Network
import NWWebSocket

class Model: ObservableObject, WebSocketConnectionDelegate {
    @Published var messages = [Message]()
    
    var socket: NWWebSocket?
    
    init() {
        socket = NWWebSocket(url: URL(string: "ws://localhost:3000")!, connectAutomatically: true)
        socket?.delegate = self
    }
    
    func send(_ message: String){
        messages.append(Message(message: message, me: true))
        socket?.send(string: message)
    }
    
    // Delegates
    func webSocketDidConnect(connection: WebSocketConnection) {
        print("connected")
    }
    
    func webSocketDidDisconnect(connection: WebSocketConnection, closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        print("disconnected")
    }
    
    func webSocketDidReceiveError(connection: WebSocketConnection, error: Error) {
        print(error)
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, string: String) {
        if messages.last?.message != string {
            DispatchQueue.main.async {
                self.messages.append(Message(message: string, me: false))
            }
        }
    }
    
    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        if let message = String(data: data, encoding: .utf8), messages.last?.message != message {
            DispatchQueue.main.async {
                self.messages.append(Message(message: message, me: false))
            }
        }
    }

    func webSocketDidReceivePong(connection: WebSocketConnection) {
        print("received pong")
    }
}
