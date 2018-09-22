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
        ChatModelController.received(message: pushedMessage, by: content.title)

        result(shouldShowNotification(for: content.title))

        guard let chat = ChatModelController.loadedChats.first(where: { (chat) -> Bool in
            chat.contact == content.title
        }) else {
            return assertionFailure("Chat for received message should always exist")
        }

        BaseNavigationViewController.navigationController?.viewControllers.forEach({ (viewController) in
            switch viewController {
            case let chatsViewController as UpdatedChatDelegate:
                chatsViewController.updated(chat: chat)
            default:
                break
            }
        })
    }

    private static func shouldShowNotification(for contact: String) -> Bool {
        let lastViewController = BaseNavigationViewController.navigationController?.viewControllers.last
        if let chatViewController = lastViewController as? ChatViewController,
            chatViewController.chat.contact == contact {
                return false
        }

        return true
    }
}
