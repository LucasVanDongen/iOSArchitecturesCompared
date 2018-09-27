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
        let shouldShowNotification: Bool
        defer {
            result(shouldShowNotification)
        }

        let content = notification.request.content
        let date = DateParser.date(from: content.subtitle) ?? Date()
        let sender: Message.Sender = .other(name: content.title)
        let pushedMessage = Message(with: sender, message: content.body, state: .sent, sendDate: date)
        ChatModelController.received(message: pushedMessage, by: content.title)

        if let chatViewController = chatViewController(handling: content.title) {
            chatViewController.received(message: pushedMessage)
            shouldShowNotification = false
        } else {
            shouldShowNotification = true
        }

        updateChats(for: content.title)
    }

    private static func updateChats(for contact: String) {
        guard let chat = ChatModelController.loadedChats.first(where: { (chat) -> Bool in
            chat.contact == contact
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

    private static func chatViewController(handling contact: String) -> ChatViewController? {
        guard let lastViewController = BaseNavigationViewController.navigationController?.viewControllers.last as? ChatViewController,
            lastViewController.chat.contact == contact else {
                return nil
        }

        return lastViewController
    }
}
