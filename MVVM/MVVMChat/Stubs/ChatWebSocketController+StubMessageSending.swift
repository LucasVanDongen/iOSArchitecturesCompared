//
//  ChatWebSocketController+StubMessageSending.swift
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

        MessageEventRouter.route(event: .received(message: message, contact: contact))
    }
}

extension ChatWebSocket: StubMessageReading {
    static func read(stub message: Message, reader: String) {
        MessageEventRouter.route(event: .otherRead(yourMessage: message, reader: reader))
    }
}
