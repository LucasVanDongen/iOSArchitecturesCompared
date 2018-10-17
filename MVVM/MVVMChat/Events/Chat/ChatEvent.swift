//
//  ChatEvent.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

enum ChatEvent {
    case started
    case loaded(chats: [Chat])

    case creating(chat: Chat)
    case created(chat: Chat)
    case createChatFailed(reason: String)
}
