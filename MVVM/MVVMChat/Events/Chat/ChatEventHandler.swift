//
//  ChatEventHandler.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

protocol ChatListListening: class {
    func updated(list: ChatListViewModel)
}

protocol CreateChatListening: class {
    func updated(create: CreateChatViewModel)
}

class ChatEventHandler {
    private static var chatListListening: [ChatListListening?] = []
    private static var createChatListening: [CreateChatListening?] = []

    class func add(listener: ChatListListening) {
        weak var weakListener = listener
        chatListListening.append(weakListener)
    }

    class func remove(listener: ChatListListening) {
        chatListListening = chatListListening.filter { $0 !== listener }
    }

    class func add(listener: CreateChatListening) {
        weak var weakListener = listener
        createChatListening.append(weakListener)
        listener.updated(create: CreateChatViewModelBuilder.build(isSending: false, error: nil))
    }

    class func remove(listener: CreateChatListening) {
        createChatListening = createChatListening.filter { $0 !== listener }
    }

    class func started() {
        DispatchQueue.global().async {
            ChatEndpoint.fetchChats()
            let loadingViewModel = ChatListViewModelBuilder.buildLoading()
            DispatchQueue.main.async {
                chatListListening.forEach { $0?.updated(list: loadingViewModel) }
            }
        }
    }

    class func loaded(chats: [Chat]) {
        let chatList = ChatListViewModelBuilder.build(for: chats)
        DispatchQueue.main.async {
            chatListListening.forEach { $0?.updated(list: chatList) }
        }
    }

    class func creatingChat() {
        let createChat = CreateChatViewModelBuilder.build(isSending: true, error: nil)
        DispatchQueue.main.async {
            createChatListening.forEach { $0?.updated(create: createChat) }
        }
    }

    class func failedCreatingChat(reason: String) {
        let createChat = CreateChatViewModelBuilder.build(isSending: false, error: reason)
        DispatchQueue.main.async {
            createChatListening.forEach { $0?.updated(create: createChat) }
        }
    }

    class func created(chat: Chat) {
        let createChat = CreateChatViewModelBuilder.build(isSending: false, error: nil)
        let chatViewController = ChatViewController(for: chat)
        DispatchQueue.main.async {
            createChatListening.forEach { $0?.updated(create: createChat) }
            updateAllChatLists()
            BaseNavigationViewController.pushViewController(chatViewController,
                                                            animated: true,
                                                            removePreviousFromStack: true)
        }
    }

    class func updateAllChatLists() {
        let chatListViewModel = ChatListViewModelBuilder.build(for: ChatModelController.allChats())
        chatListListening.forEach { $0?.updated(list: chatListViewModel) }
    }
}
