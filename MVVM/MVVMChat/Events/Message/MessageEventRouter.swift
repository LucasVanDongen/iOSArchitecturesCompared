//
//  MessageEventRouter.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 17/10/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class MessageEventRouter {
    static func route(event: MessageEvent) {
        switch event {
        case .sending(let message, let contact, let previousMessages):
            MessageEventHandler.sending(message: message, to: contact, previousMessages: previousMessages)
        case .sent(let message, let contact):
            ChatModel.sent(message: message, to: contact)
            MessageEventHandler.sent(message: message, to: contact)
        case .failedSending(let message, let contact, let reason):
            MessageEventHandler.failedSending(message: message, to: contact, reason: reason)
        case .received(let message, let contact):
            let previousMessages = ChatModel.chat(for: contact)?.messages ?? []
            ChatModel.received(message: message, by: contact)
            MessageEventHandler.received(message: message, by: contact, previousMessages: previousMessages)
        case .userRead(let contact):
            let unreadMessagesShown = ChatModel.unreadMessages(for: contact)
            ChatModel.read(others: unreadMessagesShown)
            guard !unreadMessagesShown.isEmpty else {
                return
            }
            MessageEventHandler.read(messagesBy: contact)
        case .otherRead(let yourMessage, let reader):
            ChatModel.read(yourMessage: yourMessage, reader: reader)
            MessageEventHandler.read(yourMessage: yourMessage, by: reader)
        }
    }
}
