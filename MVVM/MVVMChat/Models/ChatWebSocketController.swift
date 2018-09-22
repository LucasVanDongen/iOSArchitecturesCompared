//
//  ChatWebSocketController.swift
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

class ChatWebSocketController {
    static var currentlyConnectedContacts: [String] = []

    class func startSocket(for contact: String) {
        currentlyConnectedContacts.append(contact)
    }

    class func disconnectSocket(for contact: String) {
        currentlyConnectedContacts = currentlyConnectedContacts.filter { $0 == contact }
    }
}
