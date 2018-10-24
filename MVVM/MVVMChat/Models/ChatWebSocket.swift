//
//  ChatWebSocket.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 17/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

enum ChatWebSocketMessage {
    case new(message: Message)
    case read(message: Message)
}

class ChatWebSocket {
    static var currentlyConnectedContacts: [String] = []

    class func start(for contact: String) {
        currentlyConnectedContacts.append(contact)
    }

    class func disconnect(for contact: String) {
        currentlyConnectedContacts = currentlyConnectedContacts.filter { $0 == contact }
    }
}
