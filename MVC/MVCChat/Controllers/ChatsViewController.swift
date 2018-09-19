//
//  ChatsViewController.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 11/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

protocol UpdatedChatDelegate: class {
    func created(chat: Chat)
    func updated(chat: Chat)
}

class ChatsViewController: UIViewController {

    private lazy var customView: ChatsView = {
        let customView = ChatsView()
        customView.delegate = self
        return customView
    }()

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chats"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChat))
        navigationItem.rightBarButtonItem = addButton

        ChatModelController.fetchChats { [weak self] result in
            switch result {
            case .failed(let reason):
                print(reason)
            case .success(let chats):
                self?.customView.state = .loaded(chats: chats)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItem = nil
    }

    @objc
    private func addChat() {
        let createChatViewController = CreateChatViewController(with: self)
        BaseNavigationViewController.pushViewController(createChatViewController, animated: true)
    }

}

extension ChatsViewController: ChatsDelegate {
    func selected(chat: Chat) {
        let chatViewController = ChatViewController(for: chat, with: self)
        BaseNavigationViewController.pushViewController(chatViewController, animated: true)
    }
}

extension ChatsViewController: UpdatedChatDelegate {
    func created(chat: Chat) {
        customView.state = .loaded(chats: ChatModelController.loadedChats)
    }

    func updated(chat: Chat) {
        let unreadMessages = chat.messages.filter {
            if case .sent = $0.state,
                case .other = $0.sender {
                    return true
            }

            return false
        }
        print("😎 updated chat called for \(chat.contact), unread messages: \(unreadMessages.count)")
        customView.state = .loaded(chats: ChatModelController.loadedChats)
    }
}
