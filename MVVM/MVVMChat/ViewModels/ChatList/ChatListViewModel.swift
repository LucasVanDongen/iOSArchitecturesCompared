//
//  ChatListViewModel.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

struct ChatListViewModel {
    let hideEmptyMessage: Bool
    let hideChats: Bool
    let showSpinner: Bool
    let chats: [ChatListItemViewModel]
    let addChat: () -> Void
}
