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
            print("✄ simulated conversation for \(contact) already existed")
            return
        }

        print("✄ created new simulated conversation for \(contact)")
        let simulatedConversation = SimulatedConversation(with: contact)
        simulatedConversations.append(simulatedConversation)
    }

    class func sent(message: Message, to contact: String) {
        guard let foundConversation = simulatedConversations.first(where: { simulatedConversation in
            simulatedConversation.contact == contact
        }) else {
            print("✄ no simulated conversation found for \(contact) while sending message '\(message.message)")
            return
        }

        print("✄ reused simulated conversation with \(contact) when sending message '\(message.message)")
        let simulatedConversation = foundConversation
        simulatedConversation.receivedMessage()
        StubMessageSender.triggerResponses(in: simulatedConversation, by: message)
    }

    class func enteredChatViewController(ofConversationWith contact: String) {
        print("✄ entering chat view controller of \(contact)")
        guard let simulatedConveration = simulatedConversations.first(where: { simulatedConversation in
            simulatedConversation.contact == contact
        }) else {
            print("✄ no simulated conversation with \(contact) found when entering")
            return
        }

        simulatedConveration.enteredChatViewController()
    }

    class func leftChatViewController(ofConversationWith contact: String) {
        print("✄ leaving chat view controller of \(contact)")
        guard let simulatedConveration = simulatedConversations.first(where: { simulatedConversation in
            simulatedConversation.contact == contact
        }) else {
            print("✄ no simulated conversation with \(contact) found when leaving")
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
