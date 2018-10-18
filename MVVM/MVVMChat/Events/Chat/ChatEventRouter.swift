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
        case .applicationInitialized:
            ChatEventHandler.started()
        case .loaded(let chats):
            ChatEventHandler.loaded(chats: chats)
        case .creatingChat(let contact):
            let chat = ChatModelController.create(chatWith: contact)
            ChatEndpoint.create(chat: chat)
            ChatEventHandler.creatingChat()
        case .created(let chat):
            ChatEventHandler.created(chat: chat)
        case .createChatFailed(let reason):
            ChatEventHandler.failedCreatingChat(reason: reason)
        }
    }
}
