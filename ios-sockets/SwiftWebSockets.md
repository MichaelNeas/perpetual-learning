# Swift WebSockets

Apple delivered several exciting and innovative new API's for developers at WWDC this year.  You might have heard or read about the SwiftUI and Combine revamp, but I want to address the new world of native WebSockets!  The historically complicated connection protocol is now delivered as a first class citizen!  Before we dive in on how awesome this is, it's important to have a basic understanding of Socket's and the road we've traveled to reach this point.

## What is a socket?

By definition a **socket** is one end of a two-way communication link between two programs running on a network.  When a program runs on a network it is assigned an ip address and a port number (ie. 10.0.0.1:80). Using this data we can identify and locate the application we want to communicate with.  Let's break it down with an example! 

When we connect to a website like "www.google.com" through a web browser we have two programs running.  Those two programs are Google's web server application and the web browser application installed on our machine.  There is an ip address and port number mapped to the web address behind "www.google.com" and an unique address for our web browser.  Our computers have two sockets created to be able to **transport** information between each other.

A multitude of different protocols have been created that allow us to communicate in different ways over a network.  Most commonly we hear of **TCP/IP**, which is exactly the protocol that permits us to communicate between our web browser and Google's servers.  An **HTTP** request typically occurs over a TCP connection and brings us a few significant benefits including guaranteed delivery acknowledgement and error handling.  However, the most important aspect of this protocol is it's nature of "connectedness".  With TCP we know exactly who we're trying to communicate with, the only thing left to do is keep a connection open.

## What are WebSockets?

So we know that a socket is made when we need to communicate between applications.  We have a high level understanding of the benefits of a TCP connection.  Now we can talk about what a WebSocket is!

```
A WebSocket is a communication protocol that provides full duplex communication over a single TCP connection.
```

Let's break that statement down with an example.

If we request anything from google.com using _HTTP_ we would make a _request_ to Google's server.  **Wait**.  Hopefully we would receive a _reply_ with the information we wanted.  Then the connection is closed because we got what we needed.

With WebSockets on the other hand, we make a connection with a server and request for that connection to stay open until it times out or explicitly exited.  While that connection is persisted, both the server and client are free to pass messages over the wire.  There's no need to request and wait for a reply anymore because we leave the connection open!

It's kind of like passing notes in class versus having a string telephone with two cups on the ends to verbally communicate with someone.

WebSockets allow us to receive live updates in either direction easily.  Common use cases include:
- Multiplayer games
- Messaging platforms
- Stock market tickers
- Sports scores

## But what's going on??
At a high level there are 5 major requirements of a WebSocket connection 😄

🤝 - Handshake, when a client request to open a WebSocket with a server a negotiation happens with a `HTTP/1.1 101 Switching Protocol`.  The server and client need to check out that they want to and are allowed to open up to each other.

🔐🔗 - Connection, once the handshake is complete, a connection is made, and a bidirectional stream of data can occur between the client and server.

👂💬 - Messaging, now that the connection is up, both applications can send and receive data to each other!  We'll see shortly that the Swift API supports `String` and `Data` types.

🏓 - Ping, another important part of WebSockets is the ability to Ping/Pong each other.  A client can tell the server "Hey, I know I haven't sent a message in a while, but I'm still around so don't close me off yet!"  Pinging isn't directly required by spec but it certainly has it's common use cases.

❌ - Closure, when we're all done, a client can tell the server it wants to close off the connection and whatever reason it may have for doing so.

If you're interested in the full specification of WebSockets please checkout [RFC6455](https://tools.ietf.org/html/rfc6455), it covers all the nitty gritty details of how WebSockets should be constructed and used.

## How could we use WebSockets pre iOS13?

Back to Swift development.  Before XCode 11/iOS13 was released, WebSockets were only able to be implemented using CFNetwork or Webkit.  Where you'd either have to implement low level details or rely on JavaScript's WebSocket implementation.  

Many developers opt for 3rd party library's: 
- [Starscream](https://github.com/daltoniam/Starscream)
- [SocketRocket](https://github.com/facebook/SocketRocket)
- [Socket.io](https://github.com/socketio/socket.io-client-swift)
- [SwiftWebSocket](https://github.com/tidwall/SwiftWebSocket)

These are all still acceptable and relevant options for various use cases, but now we can move forward with a truly native Swift solution!

## What can we do now!?

```swift
import Foundation

// Create a websocket with a URL
let task = URLSession.shared.webSocketTask(with: URL(string: "wss://websocket.example")!)
// Connect, handles handshake
task.resume()

// Send "Hello!" to the server
let textMessage = URLSessionWebSocketTask.Message.string("Hello!")
task.send(textMessage) { error in /* Handle error */ }

// Listen for messages from the server
task.receive { result in /* Result type with data/string success responses */ }

task.sendPing { error in /* Handle error */ }

// Close the socket
task.cancel(with: .normalClosure, reason: nil)
```

- A webSocketTask can be created with a URL from a URLSession.  
- In order to kick off the handshake and connection we call `.resume()`.  
- From there we can use `URLSessionWebSocketDelegate` methods to confirm a successful or nonsuccessful attempt.  
- If we want to send a message `URLSessionWebSocketTask.Message` has a `.string` or `.data` method to wrap up our data to pass to the `task.send` method.  
- If we want to listen to messages that could be coming in to us we have `task.receive` that gives us a Result type which will either be `.success` with a String or Data message or `.failure` with an error.  
- Sending a ping is as simple as calling `task.sendPing` and I would advise wrapping a call to that method in a `Timer` if you have a WebSocket server that specifies a ping timeout.  
- Lastly, we have `.cancel` which takes a type of cancellation you want and an optional reason.

A more thorough implementation using `URLSessionWebSocketDelegate` can be found [here](https://github.com/MichaelNeas/perpetual-learning/blob/master/ios-sockets/SwiftWebSockets/SwiftWebSockets/Networking/NativeWebSocket.swift).

-----

#### But there's more!

```swift
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
##### or less securely:

```swift
import Network
// designate a port for the server
self.port = NWEndpoint.Port(rawValue: port)!

// create general parameters
parameters = NWParameters(tls: nil)
parameters.allowLocalEndpointReuse = true
parameters.includePeerToPeer = true

// create websocket options
let wsOptions = NWProtocolWebSocket.Options()
wsOptions.autoReplyPing = true
parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)

// Listen for incoming websocket connections
listener = try! NWListener(using: parameters, on: self.port)
```

We now have the ability to go lower level in the Network framework and create our own Swift WebSocket Server or provide custom client side WebSocket implementations.  Please view my server [implementation](https://github.com/MichaelNeas/perpetual-learning/blob/master/ios-sockets/SwiftWebSockets/SwiftWebSocketServer/SwiftWebSocketServer/SwiftWebSocketServer.swift) based off the Advances in Networking WWDC talk and a wonderful generic TCP Listener found in the credits.


## Final Words

I have made [a few projects](https://github.com/MichaelNeas/perpetual-learning/tree/master/ios-sockets) recently with the new WebSocket API's.  To see an end to end implementation please open the [WebSocket Workspace](https://github.com/MichaelNeas/perpetual-learning/blob/master/ios-sockets/SwiftWebSocketClientServer.xcworkspace).  While some of the Apple developer documentation is limited, it is fully usable and I'm excited to keep playing around!  Feel free to borrow my implementation of a [WebSocket wrapper](https://github.com/MichaelNeas/perpetual-learning/blob/master/ios-sockets/SwiftWebSockets/SwiftWebSockets/Networking/NativeWebSocket.swift). Please check out the [comparison between Starscream and Apple's implementation of client side WebSockets](https://github.com/MichaelNeas/perpetual-learning/tree/master/ios-sockets/StarscreamComparison), _(Scarily similar)_.  If you see anything you would like to add, have an issue with, or want to help out in any way, please submit a pull request or issue!


### Credits

- [Source Code](https://github.com/MichaelNeas/perpetual-learning/tree/master/ios-sockets)
- [WebSocketTask documentation](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask)
- [NWProtocolWebSocket documentation](https://developer.apple.com/documentation/network/nwprotocolwebsocket)
- [WWDC Advances in Networking, part 1](https://developer.apple.com/videos/play/wwdc2019/712/)
- [WWDC Advances in Networking, part 2](https://developer.apple.com/videos/play/wwdc2019/713/)
- [Generic TCP NWListener](https://rderik.com/blog/building-a-server-client-aplication-using-apple-s-network-framework/)

### Editors
- [Richard Bibeault](https://github.com/Duderichy)
- Tiffany Pereira