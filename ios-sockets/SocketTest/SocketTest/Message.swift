//
//  Message.swift
//  SocketTest
//
//  Created by Michael Neas on 10/4/19.
//  Copyright © 2019 Neas Lease. All rights reserved.
//

import SwiftUI

struct Message: Identifiable {
    var id = UUID()
    var message: String
    var me: Bool
}

struct MessageRow: View {
    var message: Message
    var body: some View {
        HStack {
            if message.me {
                Spacer()
            }
            Text(message.message)
                .padding(7.0)
                .font(Font.custom("Marker Felt", size: 18))
                .background(message.me ? Color.blue : Color.gray)
                .cornerRadius(20)
                .lineLimit(50)
            if !message.me {
                Spacer()
            }
        }
    }
}
