//
//  MessageEventHandler.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 17/10/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

protocol ChatListening: class {
    func updated(chat: ChatViewModel)
    func handles(chatWith contact: String) -> Bool
}

class MessageEventHandler {

    private static var chatListening: [ChatListening?] = []

    class func add(listener: ChatListening) {
        weak var weakListener = listener
        chatListening.append(weakListener)
        guard let chat = ChatModelController.allChats().first(where: { (chat) -> Bool in
            listener.handles(chatWith: chat.contact)
        }) else {
            listener.updated(chat: ChatViewModelBuilder.buildFailed(reason: "Cannot connect to chat"))
            return assertionFailure("You can't add a listener for a chat that doesn't exist")
        }

        listener.updated(chat: ChatViewModelBuilder.build(for: chat,
                                                          isSending: false,
                                                          isFirstLoad: true,
                                                          previousMessages: []))
    }

    class func remove(listener: ChatListening) {
        chatListening = chatListening.filter { $0 !== listener }
    }

    class func received(message: Message, by contact: String, previousMessages: [Message]) {
        let listenersHandlingMessage = chatListening.filter { $0?.handles(chatWith: contact) ?? false }
        updateApplicationBadge()
        ChatEventHandler.updateAllChatLists()

        guard !listenersHandlingMessage.isEmpty else {
            return
        }

        guard let chat = ChatModelController.chat(for: contact) else {
            return assertionFailure("Chat for \(contact) should exist")
        }

        let chatViewModel = ChatViewModelBuilder.build(for: chat,
                                                       isSending: false,
                                                       isFirstLoad: false,
                                                       previousMessages: previousMessages)
        listenersHandlingMessage.forEach { $0?.updated(chat: chatViewModel) }
        updateApplicationBadge()
    }

    class func sending(message: Message, to contact: String, previousMessages: [Message]) {
        guard let chat = ChatModelController.chat(for: contact) else {
            assertionFailure("Chat for \(contact) should exist")
            return
        }

        if updateListenersHandlingMessage(for: chat, previousMessages: previousMessages, isSending: true) {
            return
        }

        ChatEventHandler.updateAllChatLists()
    }

    class func sent(message: Message, to contact: String) {
        guard let chat = ChatModelController.chat(for: contact) else {
            assertionFailure("Chat for \(contact) should exist")
            return
        }

        updateListenersHandlingMessage(for: chat, previousMessages: chat.messages, isSending: false)
        ChatEventHandler.updateAllChatLists()
    }

    class func failedSending(message: Message, to contact: String, reason: String) {
        guard let chat = ChatModelController.chat(for: contact) else {
            assertionFailure("Chat for \(contact) should exist")
            return
        }

        let failedViewModel = ChatViewModelBuilder.build(for: chat,
                                                         isSending: false,
                                                         isFirstLoad: false,
                                                         error: reason)
        for case let listener in chatListening where listener?.handles(chatWith: chat.contact) ?? false {
            listener?.updated(chat: failedViewModel)
        }
    }

    class func read(messagesBy contact: String) {
        guard let chat = ChatModelController.chat(for: contact) else {
            assertionFailure("Chat for \(contact) should exist")
            return
        }

        updateListenersHandlingMessage(for: chat, isSending: false)
        ChatEventHandler.updateAllChatLists()
        updateApplicationBadge()
    }

    class func read(yourMessage: Message, by contact: String) {
        guard let chat = ChatModelController.chat(for: contact) else {
            assertionFailure("Chat for \(contact) should exist")
            return
        }

        updateListenersHandlingMessage(for: chat, isSending: false)
    }

    class func canHandleMessage(for contact: String) -> Bool {
        let listeners = chatListening.filter { $0?.handles(chatWith: contact) ?? false }
        return !listeners.isEmpty
    }

    @discardableResult
    private class func updateListenersHandlingMessage(for chat: Chat,
                                                      previousMessages: [Message]? = nil,
                                                      isSending: Bool) -> Bool {
        let listenersHandlingMessage = chatListening.filter { $0?.handles(chatWith: chat.contact) ?? false }
        if listenersHandlingMessage.isEmpty {
            return false
        }

        let chatViewModel = ChatViewModelBuilder.build(for: chat,
                                                       isSending: isSending,
                                                       isFirstLoad: false,
                                                       previousMessages: previousMessages)
        listenersHandlingMessage.forEach { $0?.updated(chat: chatViewModel) }
        return true
    }

    private class func updateApplicationBadge() {
        print("Application badge updated to \(ChatModelController.unreadMessageCount())")
        UIApplication.shared.applicationIconBadgeNumber = ChatModelController.unreadMessageCount()
    }

}
