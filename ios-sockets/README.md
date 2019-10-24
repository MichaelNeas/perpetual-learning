# Lighting Talk - October 24, 2019

### Includes
- websockets presentation slides
- SwiftWebSockets, A swiftUI chat client with a websocket networking layer
- StarscreamComparison, A comparison project between native and starscream's api implementation
- nodesocket, Node websocket server
- [blog post](./SwiftUIWebSockets.md) related to the talk


```swift
import Foundation

let task = URLSession.shared.webSocketTask(with: URL(string: "wss://websocket.example")!)
// Connect, handles handshake
task.resume()

// Send "Hello!" to the server
let dataMessage = URLSessionWebSocketTask.Message.string("Hello!")
task.send(dataMessage) { error in /* Handle error */ }

// Listen for messages from the server
task.receive { result in /* Result type with data/string success responses */ }

task.sendPing { error in /* Handle error */ }

// Close the socket
task.cancel(with: .normalClosure, reason: nil)

import Network
// Client and Server support
// Make a secure websocket over TLS
let parameters = NWParameters.tls
let websocketOptions = NWProtocolWebSocket.Options()
parameters.defaultProtocolStack.applicationProtocols.insert(websocketOptions, at: 0)

// Create a connection with those params
let websocketConnection = NWConnection(to: endpoint, using: parameters)

// Create a listener with those parameters (server)
let websocketListener = try NWListener(using: parameters)
```