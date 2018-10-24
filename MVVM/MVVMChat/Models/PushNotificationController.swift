//
//  PushNotificationController.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 17/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit
import UserNotifications

class PushNotificationController {
    class func received(notification: UNNotification, whenProcessed result: (_ shouldShow: Bool) -> Void) {
        let content = notification.request.content
        let date = DateParser.date(from: content.subtitle) ?? Date()
        let sender: Message.Sender = .other(name: content.title)
        let pushedMessage = Message(with: sender, message: content.body, state: .sent, sendDate: date)
        MessageEventRouter.route(event: .received(message: pushedMessage, contact: content.title))

        result(!MessageEventHandler.canHandleMessage(for: content.title))
    }

    class func handle(response: UNNotificationResponse) {
        let content = response.notification.request.content
        guard let chat = ChatModel.chat(for: content.title) else {
            return assertionFailure("We shouldn't get a reply on a non-existing chat in this demo")
        }

        let chatViewController = ChatViewController(for: chat)
        BaseNavigationViewController.pushViewController(chatViewController, animated: true,
                                                        removePreviousFromStack: false)
    }
}
