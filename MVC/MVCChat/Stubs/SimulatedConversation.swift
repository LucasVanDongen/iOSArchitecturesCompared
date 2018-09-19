//
//  SimulatedConversation.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 17/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class SimulatedConversation {
    enum State {
        case webSocket
        case inApp
        case appClosed
    }

    let contact: String
    var lastReceivedMessage = Date()
    var state: State = .webSocket
    init(with contact: String) {
        self.contact = contact
    }

    func receivedMessage() {
        lastReceivedMessage = Date()
    }

    func leftChatViewController() {
        state = .inApp
    }

    func leftApp() {
        state = .appClosed
    }
}
