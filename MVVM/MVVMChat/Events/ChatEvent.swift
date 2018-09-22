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

    case sending(message: Message, contact: String, previousMessages: [Message])
    case sent(message: Message, contact: String)
    case failedSending(message: Message, contact: String, reason: String)

    case received(message: Message, contact: String)
    case userRead(othersMessages: [Message], sentByContact: String)
    case otherRead(yourMessage: Message, reader: String)
}
