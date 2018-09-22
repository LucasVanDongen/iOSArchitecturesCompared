//
//  ChatWebSocketController+StubMessageSending.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 17/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

extension ChatWebSocketController: StubMessageSending {
    class func send(stub message: Message, after timeInterval: TimeInterval = 0) {
        guard case .other(let contact) = message.sender else {
            return
        }

        ChatEventRouter.route(event: .received(message: message, contact: contact))
    }
}

extension ChatWebSocketController: StubMessageReading {
    static func read(stub message: Message, reader: String) {
        ChatEventRouter.route(event: .otherRead(yourMessage: message, reader: reader))
    }
}
