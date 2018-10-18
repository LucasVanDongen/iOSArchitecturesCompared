//
//  ChatViewModelBuilder.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class ChatViewModelBuilder {
    static func build(for chat: Chat,
                      isSending: Bool,
                      isFirstLoad: Bool,
                      error: String? = nil,
                      previousMessages: [Message]? = nil) -> ChatViewModel {
        let actualPreviousMessages = previousMessages ?? chat.messages
        let messages = chat.messages.map(MessageViewModelBuilder.build)
        let differences = TableViewDataDifferentiator.differentiate(oldValues: actualPreviousMessages,
                                                                    with: chat.messages)

        return ChatViewModel(shouldAnimateChanges: isFirstLoad,
                             shouldWipeMessage: isSending,
                             shouldBeBusy: isSending,
                             shouldShowEmpty: chat.messages.isEmpty,
                             shouldShowError: error != nil,
                             error: error,
                             contact: chat.contact,
                             messages: messages,
                             tableViewDifferences: differences,
                             send: { message in send(message: message, to: chat.contact) },
                             afterShowingMessages: { afterShowingMessages(for: chat.contact) })
    }

    static func buildFailed(reason: String) -> ChatViewModel {
        return ChatViewModel(shouldAnimateChanges: false,
                             shouldWipeMessage: false,
                             shouldBeBusy: false,
                             shouldShowEmpty: false,
                             shouldShowError: true,
                             error: reason,
                             contact: "",
                             messages: [],
                             tableViewDifferences: TableViewDataDifferences.empty,
                             send: { _ in },
                             afterShowingMessages: { })
    }

    class func afterShowingMessages(for contact: String) {
        MessageEventRouter.route(event: .userRead(messagesSentBy: contact))
    }

    class func send(message: String, to contact: String) {
        ChatEndpoint.send(message: message, to: contact)
    }
}
