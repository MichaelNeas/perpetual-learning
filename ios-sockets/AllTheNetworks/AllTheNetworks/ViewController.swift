//
//  ViewController.swift
//  AllTheNetworks
//
//  Created by Michael Neas on 9/30/19.
//  Copyright © 2019 Neas Lease. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WebSocketConnectionDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var messageBox: UITextView!
    
    var socket: NativeWebSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageBox.text.removeAll()
        socket = NativeWebSocket(url: URL(string: "ws://localhost:3000")!, autoConnect: true)
        socket?.delegate = self
    }
    
    @IBAction func connect(_ sender: Any) {
        socket?.connect()
    }
    
    @IBAction func sendButton(_ sender: Any) {
        socket?.send(text: textField.text!)
    }
    
    @IBAction func disconnect(_ sender: Any) {
        socket?.disconnect()
    }
    
    func onConnected(connection: WebSocketConnection) {
        print("Connected!")
    }
    
    func onDisconnected(connection: WebSocketConnection, error: Error?) {
        print("Disconnected!")
    }
    
    func onError(connection: WebSocketConnection, error: Error) {
        print("Error \(error)")
    }
    
    func onMessage(connection: WebSocketConnection, text: String) {
        DispatchQueue.main.async {
            self.messageBox.text.append("\(text)\n")
        }
    }
    
}
