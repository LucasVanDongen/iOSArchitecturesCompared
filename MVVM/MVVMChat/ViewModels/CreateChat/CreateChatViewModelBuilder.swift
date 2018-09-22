//
//  CreateChatViewModelBuilder.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 21/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class CreateChatViewModelBuilder {
    static func build(isSending: Bool, error: String?) -> CreateChatViewModel {
        guard !isSending else {
            return CreateChatViewModel(state: .creating, create: { _ in })
        }

        if let error = error {
            return CreateChatViewModel(state: .failed(reason: error), create: create)
        }

        return CreateChatViewModel(state: .empty, create: create)
    }

    private static func create(with contact: String) {
        guard contact != "" else {
            ChatEventRouter.route(event: .createChatFailed(reason: "Please provide a contact name"))
            return
        }

        ChatEndpoint.create(chatWith: contact)
    }
}
