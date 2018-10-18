//
//  ChatListViewModelBuilder.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class ChatListViewModelBuilder {
    class func buildLoading() -> ChatListViewModel {
        return ChatListViewModel(hideEmptyMessage: false,
                                 hideChats: true,
                                 showSpinner: true,
                                 chats: [],
                                 addChat: addChat)
    }

    class func build(for chats: [Chat]) -> ChatListViewModel {
        let chatListItemViewModels = chats.map(ChatListItemViewModelBuilder.build)
        return ChatListViewModel(hideEmptyMessage: !chats.isEmpty,
                                 hideChats: chats.isEmpty,
                                 showSpinner: false,
                                 chats: chatListItemViewModels,
                                 addChat: addChat)
    }

    private class func addChat() {
        let createChatViewController = CreateChatViewController()
        BaseNavigationViewController.pushViewController(createChatViewController, animated: true)
    }
}
