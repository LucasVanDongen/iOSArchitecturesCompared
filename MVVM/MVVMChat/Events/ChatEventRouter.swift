//
//  ChatEventRouter.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class ChatEventRouter {
    static func route(event: ChatEvent) {
        switch event {
        case .started:
            ChatEventHandler.started()
        case .loaded(let chats):
            ChatEventHandler.loaded(chats: chats)
        case .creating(let chat):
            ChatEventHandler.creatingChat()
        case .created(let chat):
            // TODO: navigation implementation shouldn't happen here
            let chatViewController = ChatViewController(for: chat)
            BaseNavigationViewController.pushViewController(chatViewController,
                                                            animated: true,
                                                            removePreviousFromStack: true)
            ChatEventHandler.created(chat: chat)
        case .createChatFailed(let reason):
            ChatEventHandler.failedCreatingChat(reason: reason)
        case .sending(let message, let contact, let previousMessages):
            ChatEventHandler.sending(message: message, to: contact, previousMessages: previousMessages)
        case .sent(let message, let contact):            ChatModelController.sent(message: message, to: contact)
            ChatEventHandler.sent(message: message, to: contact)
        case .failedSending(let message, let contact, let reason):
            ChatEventHandler.failedSending(message: message, to: contact, reason: reason)
        case .received(let message, let contact):
            let previousMessages = ChatModelController.chat(for: contact)?.messages ?? []
            ChatModelController.received(message: message, by: contact)
            ChatEventHandler.received(message: message, by: contact, previousMessages: previousMessages)
        case .userRead(let othersMessages, let contact):
            ChatModelController.read(others: othersMessages)
            ChatEventHandler.read(messagesBy: contact)
        case .otherRead(let yourMessage, let reader):
            ChatModelController.read(yourMessage: yourMessage, reader: reader)
            ChatEventHandler.read(yourMessage: yourMessage, by: reader)
        }
    }
}
