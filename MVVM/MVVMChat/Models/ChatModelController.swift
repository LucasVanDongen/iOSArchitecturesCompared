//
//  ChatModelController.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 13/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class ChatModelController {

    private static var loadedChats: [Chat] = []

    class func create(chatWith contact: String) -> Chat {
        let chat = Chat(with: contact)
        loadedChats.append(chat)
        return chat
    }

    class func create(message: String, to contact: String) -> Message {
        print("adding message \(message) to \(contact)")
        let chat: Chat
        if let foundChat = loadedChats.first(where: { $0.contact == contact }) {
            chat = foundChat
        } else {
            chat = Chat(with: contact)
        }

        let createdMessage = Message(with: .user, message: message, state: .sending, sendDate: Date())
        chat.messages.append(createdMessage)

        return createdMessage
    }

    class func sent(message: Message, to contact: String) {
        message.sent()
    }

    class func load(chats: [Chat]) {
        loadedChats = chats
    }

    class func received(message: Message, by contact: String) {
        let chat: Chat
        print("received message \(message.message) by \(contact)")
        if let foundChat = loadedChats.first(where: { (chat) -> Bool in
            chat.contact == contact
        }) {
            chat = foundChat
        } else {
            chat = create(chatWith: contact)
        }

        chat.messages.append(message)
    }

    static func read(yourMessage message: Message, reader: String) {
        message.read(readDate: Date())
    }

    static func read(others messages: [Message]) {
        messages.forEach { $0.read(readDate: Date()) }
    }

    static func chat(for contact: String) -> Chat? {
        return loadedChats.first(where: { $0.contact == contact })
    }

    static func allChats() -> [Chat] {
        return loadedChats
    }

    static func unreadMessageCount() -> Int {
        return loadedChats.flatMap { $0.messages }.filter(isUnreadByUser).count
    }

    static func unreadMessages(for contact: String) -> [Message] {
        guard let messages = chat(for: contact)?.messages else {
            return []
        }

        return messages.filter(isUnreadByUser)
    }

    private static func isUnreadByUser(message: Message) -> Bool {
        switch (message.state, message.sender) {
        case (.read, _), (_, .user): return false
        case (.sending, .other), (.sent, .other): return true
        }
    }
}
