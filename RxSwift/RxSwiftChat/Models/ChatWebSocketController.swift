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
    static var currentConnections: [String: (ChatWebSocketMessage) -> Void] = [:]

    class func startSocket(for chat: Chat, whenReceiving received: @escaping (ChatWebSocketMessage) -> Void) {
        currentConnections[chat.contact] = received
    }

    class func disconnectSocket(for chat: Chat) {
        currentConnections.removeValue(forKey: chat.contact)
    }
}
