//
//  ChatEndpoint.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class ChatEndpoint {
    class func fetchChats() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let contact = "John"
            let newMessage = Message(with: .other(name: contact),
                                     message: "Hi, you're here too?",
                                     state: .sent,
                                     sendDate: Date().addingTimeInterval(-500))

            let chats = [Chat(with: contact, messages: [newMessage])]
            ChatModel.load(chats: chats)
            ChatEventRouter.route(event: .loaded(chats: chats))
        }
    }

    static func create(chat: Chat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ChatEventRouter.route(event: .created(chat: chat))
        }
    }

    class func send(message: String, to contact: String) {
        let previousMessages = ChatModel.chat(for: contact)?.messages ?? []
        let newMessage = ChatModel.create(message: message, to: contact)
        let event = MessageEvent.sending(message: newMessage, contact: contact, previousMessages: previousMessages)
        MessageEventRouter.route(event: event)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            MessageEventRouter.route(event: .sent(message: newMessage, contact: contact))
            ConversationSimulator.sent(message: newMessage, to: contact)
        }
    }

    static func read(messages: [Message]) {
        messages.forEach { (message) in
            message.read(readDate: Date())
        }
    }
}
