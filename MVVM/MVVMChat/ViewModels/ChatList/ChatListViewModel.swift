//
//  ChatListViewModel.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

struct ChatListViewModel {
    enum State {
        case empty
        case loading
        case loaded(chats: [ChatListItemViewModel])
    }

    let state: State
    let addChat: () -> Void
}
