//
//  Chat.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 13/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class Chat {
    let contact: String
    var messages: [Message]
    var unreadMessages: Int {
        return messages.filter {
            switch ($0.sender, $0.state) {
            case (.user, _), (.other, .read): return false
            case (.other, .sending), (.other, .sent): return true
            }
        }.count
    }
    var lastMessage: Date? {
        return messages.last?.sendDate
    }

    init(with contact: String, messages: [Message] = []) {
        self.contact = contact
        self.messages = messages
    }
}
