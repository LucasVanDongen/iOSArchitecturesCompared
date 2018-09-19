//
//  ChatModelController.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 13/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

enum ChatsFetchResult {
    case failed(reason: String)
    case success(chats: [Chat])
}

enum ChatCreateResult {
    case failed(reason: String)
    case reused(chat: Chat)
    case success(createdChat: Chat)
}

enum SendMessageUpdate {
    case failed(reason: String)
    case sending(message: Message, updatingChat: Chat)
    case sent(message: Message, updatedChat: Chat)
}

enum ReadMessageUpdate {
    case failed(reason: String)
    case locallyUpdated(chat: Chat)
    case remoteUpdated(chat: Chat)
}

class ChatModelController {
    private(set) static var loadedChats: [Chat] = []
    class func fetchChats(whenDone result: @escaping (ChatsFetchResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard loadedChats.isEmpty else {
                result(.success(chats: loadedChats))
                return
            }

            let message = Message(with: .other(name: "John"),
                                  message: "Hi, you're here too?", state: .sent,
                                  sendDate: Date().addingTimeInterval(-500))
            let chats = [
                Chat(with: "John", messages: [message])
            ]
            loadedChats = chats
            result(.success(chats: chats))
        }
    }

    class func createChat(for contact: String, whenDone result: @escaping (ChatCreateResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let existingChat = loadedChats.first(where: { (chat) -> Bool in
                chat.contact == contact
            })
            if let existingChat = existingChat {
                return result(.reused(chat: existingChat))
            }

            let chat = Chat(with: contact, messages: [])
            loadedChats.insert(chat, at: 0)
            result(.success(createdChat: chat))
        }
    }

    class func send(message: String, to chat: Chat, whenUpdated update: @escaping (SendMessageUpdate) -> Void) {
        guard let chat = loadedChats.first(where: { $0.contact == chat.contact }) else {
            return update(.failed(reason: "Chat you're sending to doesn't or no longer seems to exist"))
        }

        let sendingMessage = Message(with: .user, message: message, state: .sending, sendDate: Date())
        chat.messages.append(sendingMessage)
        update(.sending(message: sendingMessage, updatingChat: chat))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard let chat = loadedChats.first(where: { $0.contact == chat.contact }),
                let message = chat.messages.first(where: { $0.sendDate == sendingMessage.sendDate
            }) else {
                return update(.failed(reason:
                    "Chat you're sending to or message you're trying to send doesn't or no longer seems to exist"))
            }

            message.sent()
            update(.sent(message: message, updatedChat: chat))
        }
    }

    class func received(message: Message, by contact: String) {
        guard let chat = loadedChats.first(where: { (chat) -> Bool in
            chat.contact == contact
        }) else {
            return assertionFailure("The chat being responded to should exist")
        }

        chat.messages.append(message)
    }

    static func read(messages: [Message], from chat: Chat, whenUpdated update: @escaping (ReadMessageUpdate) -> Void) {
        guard let chat = loadedChats.first(where: { $0.contact == chat.contact }) else {
            return update(.failed(reason: "Chat you're reading doesn't or no longer seems to exist"))
        }

        messages.forEach { (message) in
            message.read(readDate: Date())
        }
        update(.locallyUpdated(chat: chat))
        updateUnread()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // No action taken after "sending" the read message
        }
    }

    static func read(yourMessage message: Message, reader sender: Message.Sender) {
        guard case .other(let contact) = sender,
            let chat = loadedChats.first(where: { $0.contact == contact }),
            let message = chat.messages.first(where: { $0.sendDate == message.sendDate }) else {
                return assertionFailure("Your message being read should exist")
        }

        message.read(readDate: Date())
    }

    private static func updateUnread() {
        let newUnreadTotal = loadedChats.flatMap { $0.messages }.filter({ (message) -> Bool in
            if case Message.State.read = message.state {
                return false
            }

            return true
        }).count
        UIApplication.shared.applicationIconBadgeNumber = newUnreadTotal
    }
}
