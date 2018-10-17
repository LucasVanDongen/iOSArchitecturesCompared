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
        let create = isSending ? { _ in } : self.create
        return CreateChatViewModel(hideError: error == nil,
                                   enableCreate: !isSending,
                                   showSpinner: isSending,
                                   error: error ?? "",
                                   create: create)
    }

    private static func create(with contact: String) {
        guard contact != "" else {
            ChatEventRouter.route(event: .createChatFailed(reason: "Please provide a contact name"))
            return
        }

        ChatEndpoint.create(chatWith: contact)
    }
}
