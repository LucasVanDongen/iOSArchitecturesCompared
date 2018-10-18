//
//  MessageEvent.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 17/10/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

enum MessageEvent {
    case sending(message: Message, contact: String, previousMessages: [Message])
    case sent(message: Message, contact: String)
    case failedSending(message: Message, contact: String, reason: String)

    case received(message: Message, contact: String)
    case userReads(messagesSentBy: String)
    case userRead(othersMessages: [Message], sentBy: String)
    case otherRead(yourMessage: Message, reader: String)
}
