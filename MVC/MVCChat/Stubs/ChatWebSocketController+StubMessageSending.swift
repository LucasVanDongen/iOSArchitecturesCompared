//
//  ChatWebSocket+StubMessageSending.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 17/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

extension ChatWebSocket: StubMessageSending {
    class func send(stub message: Message, after timeInterval: TimeInterval = 0) {
        guard case .other(let contact) = message.sender else {
            return
        }

        ChatModel.received(message: message, by: contact)
        currentConnections[contact]?(.new(message: message))
    }
}

extension ChatWebSocket: StubMessageReading {
    static func read(stub message: Message, reader sender: Message.Sender) {
        ChatModel.read(yourMessage: message, reader: sender)
        guard case .other(let contact) = sender,
            let chatIndex = ChatModel.loadedChats.index(where: { (chat) -> Bool in
                chat.contact == contact
            }) else {
                return assertionFailure("This chat should exist")
        }

        guard let messageIndex = ChatModel.loadedChats[chatIndex].messages
            .index(where: { (existingMessage) -> Bool in
                message.sendDate == existingMessage.sendDate
        }) else {
            return assertionFailure("This message should exist")
        }

        let updatedMessage = ChatModel.loadedChats[chatIndex].messages[messageIndex]
        currentConnections[contact]?(.read(message: updatedMessage))
    }
}
