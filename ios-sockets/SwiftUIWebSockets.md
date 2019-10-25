# Swift WebSockets & SwiftUI

Apple delivered some incredibly exciting and innovative new API's for developers at WWDC this year.  You might have heard and read about the SwiftUI and Combine revamp but I want to address a different API that should certainly gain more recognition.  It all has to do with WebSockets!  The historically unnecessarily complicated connection protocol has now been delivered as a first class citizen!  Before we can dive in on how awesome this really is, it's important to gain a basic understanding of what a Socket is and the road we've traveled to reach this point.

## What is a socket?

By definition a **socket** is one end of a two-way communication link between two programs running on a network.  When a program is running on a network it is assigned an ip address and a port number (ie. 10.0.0.1:80). Using this combination of data we can identify and locate the application we want to communicate with.  Let's break it down with an example! 

When we need to connect to a website like "www.google.com" through a web browser we have two programs running.  Those two programs are Google's web server application and our web browser application installed on our machine.  There is actually an ip address and port number mapped to the web address behind "www.google.com" and there is an unique address for our web browser.  Our computers have two sockets created to be able to **transport** information between each other.

A multitude of different protocols have been created that allow us to communicate in different ways over a network.  Most commonly we hear of **TCP/IP**, which is exactly the protocol set up to communicate between our web browser and Google's servers.  An **HTTP** request typically occurs over a TCP connection and this brings us a few large benefits such as guaranteed delivery acknowledgement and error handling.  However the most important aspect of this protocol is it's nature of "connectedness".  With TCP we know who we're trying to communicate with and can leverage the standard to persist it's connection.

## What are WebSockets?

Now that we know that a socket is made when we need to communicate between applications and a high level understanding of the benefits of a TCP connection, we can now talk about what a WebSocket is!

```
A WebSocket is a communication protocol that provides full duplex communication over a single TCP connection.
```

Let's break that statement down with an example.

If we were requesting something from google.com using an HTTP request we would make a _request_ to Google's server, wait, and they would hopefully give us a nice _reply_ with the information we wanted and we close the connection because we got what we needed.

With WebSockets on the other hand, we make a connection with a server and ask for that connection to stay open until it is timed out or explicitly told to exit.  While that connection is continually established, both the server and client are free to pass messages over the wire.  There's no need to request and wait for a reply anymore because we just leave the connection open!

It's kind of like passing notes in class versus having a string telephone with two cups on the ends to verbally communicate with someone.

WebSockets allow us to receive live updates in either direction easily.  Common use cases include:
- Multiplayer games
- Messaging platforms
- Stock market tickers
- Sports scores

## But what's going on??
At a high level there are 5 major requirements of a WebSocket connection and we can use emojis to represent each part.

🤝 - The handshake phase, when a client request to open a WebSocket with a server a negotiation happens with a `HTTP/1.1 101 Switching Protocol`.  Basically the server and client need to check out that they want to and are allowed to open up to each other.

🔐🔗 - Once the handshake is complete, a connection is made, and a bidirectional stream of data can occur between the client and server.  This connection heavily relies on the socket definition from above.

👂💬 - Now that the connection is up, both applications can send and receive data to each other!  We'll see shortly that the swift api supports `String` and `Data` types.

🏓 - Another important part of WebSockets is the ability to Ping/Pong each other.  A client can tell the server "Hey, I know I haven't sent a message in a while, but I'm still around so don't close me off yet!"  Pinging isn't directly required by spec but it certainly has it's common use cases.

❌ - Lastly when we're all done, a client can tell the server it wants to close off the connection and whatever reason it may have for doing so.

If you're interested in the fully defined specification of websockets please checkout [RFC6455](https://tools.ietf.org/html/rfc6455), it covers all the nitty gritty details of how WebSockets should be constructed and used.

## How could we use WebSockets pre iOS13?

Back to iOS development.  Before XCode 11/iOS13, WebSockets were only able to be implemented using CFNetwork or Webkit.  Where you'd either have to deal with low level implementation details or rely on JavaScript's WebSocket implementation.  

Many people opt for 3rd party library's like: 
- [Starscream](https://github.com/daltoniam/Starscream)
- [SocketRocket](https://github.com/facebook/SocketRocket)
- [Socket.io](https://github.com/socketio/socket.io-client-swift)
- [SwiftWebSocket](https://github.com/tidwall/SwiftWebSocket)

And these are all still fine and certainly relevant options, but now we can move forward with a truly native Swift solution!

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

#### And that's really all there is to it!

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

We also now have the ability to go lower level in the Network framework and create our own Swift WebSocket Server or provide custom client side WebSocket implementations.  I'm currently working on a WebSocket server [implementation](https://github.com/MichaelNeas/perpetual-learning/blob/master/ios-sockets/SwiftWebSockets/SwiftWebSockets/Networking/NativeWebSocketServer.swift) based off the Advances in Networking WWDC talk.


## Final Words

I have made [a few projects](https://github.com/MichaelNeas/perpetual-learning/tree/master/ios-sockets) now with the new WebSocket API's.  While some of the Apple developer documentation is limited, it is fully usable and I'm so excited to keep playing around.  Feel free to borrow my implementation of a [WebSocket wrapper](https://github.com/MichaelNeas/perpetual-learning/blob/master/ios-sockets/SwiftWebSockets/SwiftWebSockets/Networking/NativeWebSocket.swift) Please check out the [comparison between Starscream and Apple's implementation of client side WebSockets](https://github.com/MichaelNeas/perpetual-learning/tree/master/ios-sockets/StarscreamComparison), _(It's scary similar)_.  If you see something you want to add, have an issue with, or want to help out in any way, definitely go for it!


### Credits

- [Source Code](https://github.com/MichaelNeas/perpetual-learning/tree/master/ios-sockets)
- [WebSocketTask documentation](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask)
- [NWProtocolWebSocket documentation](https://developer.apple.com/documentation/network/nwprotocolwebsocket)
- [WWDC Advances in Networking, part 1](https://developer.apple.com/videos/play/wwdc2019/712/)
- [WWDC Advances in Networking, part 2](https://developer.apple.com/videos/play/wwdc2019/713/)
