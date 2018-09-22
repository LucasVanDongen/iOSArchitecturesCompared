//
//  ChatListItemViewModel.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

struct ChatListItemViewModel {
    let contact: String
    let message: String
    let lastMessageDate: String
    let unreadMessageCount: Int
    let itemTapped: () -> Void
}
