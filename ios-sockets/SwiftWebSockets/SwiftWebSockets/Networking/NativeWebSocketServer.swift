//
//  NativeWebSocketServer.swift
//  SwiftWebSockets
//
//  Influenced by WWDC 2019 Networking part 1
//

import Foundation
import Network

class NativeWebSocketServer {
    
    static var shared = NativeWebSocketServer()
    
    let listener: NWListener
    var connectedClients: [NWConnection] = []
    
    init() {
        let tlsOptions = NWProtocolTLS.Options()
        //configureLocalIdentity(on: tlsOptions)
//        let identity = SecIdentity
//        sec_protocol_options_set_local_identity(tlsOptions, )
        let params = NWParameters(tls: tlsOptions)
        let wsOptions = NWProtocolWebSocket.Options()
        // handshake
        wsOptions.autoReplyPing = true
        params.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)
        
        do {
            listener = try NWListener(using: params, on: 3000)
            let serverQueue = DispatchQueue(label: "serverQueue")
            
            listener.newConnectionHandler = { newConnection in
                self.connectedClients.append(newConnection)
                newConnection.start(queue: serverQueue)
                
                func receive() {
                    newConnection.receiveMessage { (data, context, isComplete, error) in
                        if let data = data, let context = context {
                            self.handleMessage(data: data, context: context)
                            receive()
                        }
                    }
                }
                receive()
            }
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    func sendUpdates(items: [String]) throws {
        let data = try JSONEncoder().encode(items)
        
        for client in connectedClients {
            let metaData = NWProtocolWebSocket.Metadata(opcode: .binary)
            let context = NWConnection.ContentContext (identifier: "context", metadata: [metaData])
            client.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed( { _ in } ))
        }
    }
    
    func handleMessage(data: Data, context: NWConnection.ContentContext) {
        //handle incoming message
    }
    
}
