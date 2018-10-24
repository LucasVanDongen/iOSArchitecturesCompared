//
//  AppDelegate.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 11/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options:
            [[.alert, .sound, .badge]],
                                                                completionHandler: { _, _ in
                                                                    // Handle Error
        })
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        ConversationSimulator.leftApplication()
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler
                                    completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        PushNotificationController.received(notification: notification) { shouldShowNotification in
            guard shouldShowNotification else {
                completionHandler([])
                return
            }
            completionHandler([.badge, .sound, .alert])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        guard let chat = ChatModel.loadedChats.first(where: { (chat) -> Bool in
            chat.contact == content.title
        }) else {
            assertionFailure("We shouldn't get a reply on a non-existing chat in this demo")
            completionHandler()
            return
        }

        let viewControllers = BaseNavigationViewController.navigationController?.viewControllers
        guard let chatsViewController = viewControllers?.first(where: { (viewController) -> Bool in
            viewController is ChatsViewController
        }) as? ChatsViewController else {
            assertionFailure("ChatsViewController should always be at the root")
            completionHandler()
            return
        }

        BaseNavigationViewController.navigationController?.popViewController(animated: false)
        let chatViewController = ChatViewController(for: chat, with: chatsViewController)
        BaseNavigationViewController.pushViewController(chatViewController, animated: true,
                                                        removePreviousFromStack: false)
        completionHandler()
    }
}
