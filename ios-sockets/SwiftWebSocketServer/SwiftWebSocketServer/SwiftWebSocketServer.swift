//
//  SwiftWebSocketServer.swift
//  SwiftSocketServer
//
//  Created by Michael Neas on 11/30/19.
//  Copyright © 2019 Neas Lease. All rights reserved.
//

import Foundation
import Network

class SwiftWebSocketServer {
    let port: NWEndpoint.Port
    let listener: NWListener
    let parameters: NWParameters

    private var connectionsByID: [Int: ServerConnection] = [:]

    init(port: UInt16) {
        self.port = NWEndpoint.Port(rawValue: port)!
        parameters = NWParameters(tls: nil)
        parameters.allowLocalEndpointReuse = true
        parameters.includePeerToPeer = true
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true
        parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)
        listener = try! NWListener(using: parameters, on: self.port)
    }

    func start() throws {
        print("Server starting...")
        listener.stateUpdateHandler = self.stateDidChange(to:)
        listener.newConnectionHandler = self.didAccept(nwConnection:)
        listener.start(queue: .main)
    }

    func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .ready:
            print("Server ready.")
        case .failed(let error):
            print("Server failure, error: \(error.localizedDescription)")
            exit(EXIT_FAILURE)
        default:
            break
        }
    }

    private func didAccept(nwConnection: NWConnection) {
        let connection = ServerConnection(nwConnection: nwConnection)
        connectionsByID[connection.id] = connection
        
        connection.start()
        
        connection.didStopCallback = { [weak self] err in
            if let err = err {
                print(err)
            }
            self?.connectionDidStop(connection)
        }
        connection.didReceive = { [weak self] data in
            self?.connectionsByID.values.forEach { connection in
                print("sent \(String(data: data, encoding: .utf8) ?? "NOTHING") to open connection \(connection.id)")
                connection.send(data: data)
            }
        }
        
        connection.send(data: "Welcome you are connection: \(connection.id)".data(using: .utf8)!)
        print("server did open connection \(connection.id)")
    }

    private func connectionDidStop(_ connection: ServerConnection) {
        self.connectionsByID.removeValue(forKey: connection.id)
        print("server did close connection \(connection.id)")
    }

    private func stop() {
        self.listener.stateUpdateHandler = nil
        self.listener.newConnectionHandler = nil
        self.listener.cancel()
        for connection in self.connectionsByID.values {
            connection.didStopCallback = nil
            connection.stop()
        }
        self.connectionsByID.removeAll()
    }
}

class ServerConnection {
    private static var nextID: Int = 0
    let connection: NWConnection
    let id: Int

    init(nwConnection: NWConnection) {
        connection = nwConnection
        id = ServerConnection.nextID
        ServerConnection.nextID += 1
    }
    
    deinit {
        print("deinit")
    }

    var didStopCallback: ((Error?) -> Void)? = nil
    var didReceive: ((Data) -> ())? = nil

    func start() {
        print("connection \(id) will start")
        connection.stateUpdateHandler = self.stateDidChange(to:)
        setupReceive()
        connection.start(queue: .main)
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            print("connection \(id) ready")
        case .failed(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }

    private func setupReceive() {
        connection.receiveMessage() { [weak self] (data, context, isComplete, error) in
            if let data = data, let context = context, !data.isEmpty {
                self?.handleMessage(data: data, context: context)
            }
            if let error = error {
                self?.connectionDidFail(error: error)
            } else {
                self?.setupReceive()
            }
        }
    }
    
    func handleMessage(data: Data, context: NWConnection.ContentContext) {
        didReceive?(data)
    }


    func send(data: Data) {
        let metaData = NWProtocolWebSocket.Metadata(opcode: .binary)
        let context = NWConnection.ContentContext (identifier: "context", metadata: [metaData])
        connection.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed( { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
            print("connection \(self.id) did send, data: \(data as NSData)")
        }))
    }

    func stop() {
        print("connection \(id) will stop")
    }

    private func connectionDidFail(error: Error) {
        print("connection \(id) did fail, error: \(error)")
        stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection \(id) did end")
        stop(error: nil)
    }

    private func stop(error: Error?) {
        connection.stateUpdateHandler = nil
        connection.cancel()
        if let didStopCallback = didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
        didReceive = nil
    }
}
