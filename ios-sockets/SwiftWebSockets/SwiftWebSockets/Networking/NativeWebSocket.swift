//
//  NativeWebSocket.swift
//  SocketTest
//
//  Created by Michael Neas on 10/4/19.
//  Copyright © 2019 Neas Lease. All rights reserved.
//

import Foundation
import Network

/// Defines a websocket connection.
protocol WebSocketConnection {
    /// Connect to the websocket.
    func connect()

    /// Send a UTF-8 formatted `String` over the websocket.
    /// - Parameter string: The `String` that will be sent.
    func send(string: String)

    /// Send some `Data` over the websocket.
    /// - Parameter data: The `Data` that will be sent.
    func send(data: Data)

    /// Start listening for messages over the websocket.
    func listen()

    /// Ping the websocket periodically.
    /// - Parameter interval: The `TimeInterval` (in seconds) with which to ping the server.
    func ping(interval: TimeInterval)

    /// Ping the websocket once.
    func ping()

    /// Disconnect from the websocket.
    /// - Parameter closeCode: The code to use when closing the websocket connection.
    func disconnect(closeCode: NWProtocolWebSocket.CloseCode)

    var delegate: WebSocketConnectionDelegate? { get set }
}

/// Defines a delegate for a websocket connection.
protocol WebSocketConnectionDelegate: AnyObject {
    func webSocketDidConnect(connection: WebSocketConnection)
    func webSocketDidDisconnect(connection: WebSocketConnection,
                                closeCode: NWProtocolWebSocket.CloseCode,
                                reason: Data?)
    func webSocketDidReceiveError(connection: WebSocketConnection, error: Error)
    func webSocketDidReceivePong(connection: WebSocketConnection)
    func webSocketDidReceiveMessage(connection: WebSocketConnection, string: String)
    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data)
}


class NativeWebSocket: NSObject, WebSocketConnection, URLSessionWebSocketDelegate {
    weak var delegate: WebSocketConnectionDelegate?
    var webSocketTask: URLSessionWebSocketTask!
    var urlSession: URLSession!
    let delegateQueue = OperationQueue()
    private var pingTimer: Timer?
    
    init(url: URL, autoConnect: Bool = false) {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
        webSocketTask = urlSession.webSocketTask(with: url)
        if autoConnect {
            connect()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        delegate?.onConnected(connection: self)
//        DispatchQueue.main.async { [weak self] in
//            self?.ping()
//        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        delegate?.onDisconnected(connection: self, error: nil)
    }
    
    func connect() {
        // required to open socket
        webSocketTask.resume()
        listen()
    }
    
    func send(text: String) {
        let textMessage = URLSessionWebSocketTask.Message.string(text)
        webSocketTask.send(textMessage) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.onError(connection: self, error: error)
            }
        }
    }
    
    func send(data: Data) {
        let dataMessage = URLSessionWebSocketTask.Message.data(data)
        webSocketTask.send(dataMessage) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.onError(connection: self, error: error)
            }
        }
    }
    
    // Be aware that if you want to receive messages continuously you need to call this again after you’ve finished receiving a message. One way is to wrap this in a function and call the same function recursively.
    func listen()  {
        webSocketTask.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.delegate?.onError(connection: self, error: error)
            case .success(let message):
                switch message {
                case .string(let text):
                    self.delegate?.onMessage(connection: self, text: text)
                case .data(let data):
                    self.delegate?.onMessage(connection: self, data: data)
                @unknown default:
                    fatalError()
                }
            }
            self.listen()
        }
    }
    
    func ping(with frequency: TimeInterval = 25.0) {
        pingTimer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.webSocketTask.sendPing { error in
                if let error = error {
                    self.delegate?.onError(connection: self, error: error)
                }
            }
        }
    }
    
    func disconnect() {
        webSocketTask.cancel(with: .normalClosure, reason: nil)
        pingTimer?.invalidate()
    }
}
