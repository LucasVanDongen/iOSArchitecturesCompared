//
//  ConversationSimulator.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 17/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class ConversationSimulator {
    private static var simulatedConversations = [SimulatedConversation]()

    class func createdConversation(with contact: String) {
        guard !simulatedConversations.contains(where: { simulatedConversation in
            simulatedConversation.contact == contact
        }) else {
            return
        }

        let simulatedConversation = SimulatedConversation(with: contact)
        simulatedConversations.append(simulatedConversation)
    }

    class func sent(message: Message, to contact: String) {
        guard let foundConversation = simulatedConversations.first(where: { simulatedConversation in
            simulatedConversation.contact == contact
        }) else {
            return
        }

        let simulatedConversation = foundConversation
        simulatedConversation.receivedMessage()
        StubMessageSender.triggerResponses(in: simulatedConversation, by: message)
    }

    class func enteredChatViewController(ofConversationWith contact: String) {
        guard let simulatedConveration = simulatedConversations.first(where: { simulatedConversation in
            simulatedConversation.contact == contact
        }) else {
            return
        }

        simulatedConveration.enteredChatViewController()
    }

    class func leftChatViewController(ofConversationWith contact: String) {
        guard let simulatedConveration = simulatedConversations.first(where: { simulatedConversation in
            simulatedConversation.contact == contact
        }) else {
            return
        }

        simulatedConveration.leftChatViewController()
    }

    class func leftApplication() {
        simulatedConversations.forEach { (conversation) in
            conversation.leftApp()
            StubMessageSender.sendGoodbyes()
        }
    }
}
