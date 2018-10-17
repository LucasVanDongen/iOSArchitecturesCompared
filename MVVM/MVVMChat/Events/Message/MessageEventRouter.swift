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
            ChatModelController.sent(message: message, to: contact)
            MessageEventHandler.sent(message: message, to: contact)
        case .failedSending(let message, let contact, let reason):
            MessageEventHandler.failedSending(message: message, to: contact, reason: reason)
        case .received(let message, let contact):
            let previousMessages = ChatModelController.chat(for: contact)?.messages ?? []
            ChatModelController.received(message: message, by: contact)
            MessageEventHandler.received(message: message, by: contact, previousMessages: previousMessages)
        case .userRead(let othersMessages, let contact):
            ChatModelController.read(others: othersMessages)
            MessageEventHandler.read(messagesBy: contact)
        case .otherRead(let yourMessage, let reader):
            ChatModelController.read(yourMessage: yourMessage, reader: reader)
            MessageEventHandler.read(yourMessage: yourMessage, by: reader)
        }
    }

}
