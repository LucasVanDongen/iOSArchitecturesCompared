//
//  ChatViewController.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 11/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    private lazy var customView: ChatView = {
        let customView = ChatView(frame: CGRect(x: 0, y: 64, width: 320, height: 500))
        customView.delegate = self
        return customView
    }()

    let chat: Chat
    private weak var delegate: UpdatedChatDelegate?

    init(for chat: Chat, with delegate: UpdatedChatDelegate) {
        self.chat = chat
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a new stub message sending object
        ConversationSimulator.createdConversation(with: chat.contact)

        title = chat.contact
        ChatWebSocketController.startSocket(for: chat) { [weak self] (message) in
            guard let chat = self?.chat,
                let messages = ChatModelController.loadedChats.first(where: { (loadedChat) -> Bool in
                chat.contact == loadedChat.contact
            })?.messages else {
                return assertionFailure("Chat for this socket cannot be found")
            }

            guard let strongSelf = self else {
                return
            }

            switch message {
            case .new(let message):
                strongSelf.customView.configure(with: messages)
                strongSelf.delegate?.updated(chat: chat)
                strongSelf.read(messages: [message])
            case .read:
                strongSelf.customView.configure(with: messages)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Dirty trick to not disturb the segue animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.customView.configure(with: self.chat.messages)
            self.read(messages: self.chat.messages)
        }

        // Start receiving fake responses through the websocket again
        ConversationSimulator.enteredChatViewController(ofConversationWith: chat.contact)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        ChatWebSocketController.disconnectSocket(for: chat)
        // Stop receiving fake responses through the websocket
        ConversationSimulator.leftChatViewController(ofConversationWith: chat.contact)
    }

    func read(messages: [Message]) {
        // Only update the unread message when it's the other's message and still unread
        let messagesThatShouldBeFlaggedRead = messages.filter { (message) -> Bool in
            guard case .other = message.sender,
                case .sent = message.state else {
                    return false
            }

            return true
        }

        ChatModelController.read(messages: messagesThatShouldBeFlaggedRead, from: chat) { [weak self] update in
            switch update {
            case .failed(let reason):
                self?.customView.state = .failed(reason: reason)
            case .locallyUpdated(let chat):
                self?.delegate?.updated(chat: chat)
            case .remoteUpdated(let chat):
                self?.delegate?.updated(chat: chat)
            }
        }
    }
}

extension ChatViewController: ChatDelegate {
    func send(message: String) {
        guard message.count > 0 else {
            customView.state = .failed(reason: "Enter a message!")
            return
        }

        ChatModelController.send(message: message, to: chat) { [weak self] result in
            defer {
                if case .sent(let message, let chat) = result {
                    // Used to simulate somebody giving responses
                    ConversationSimulator.sent(message: message, to: chat.contact)
                }
            }

            guard let strongSelf = self else {
                return
            }

            let updatedChat: Chat
            switch result {
            case .failed(let reason):
                strongSelf.customView.state = .failed(reason: reason)
                return
            case .sending(_, let chat):
                strongSelf.customView.state = .sending(updatingMessages: chat.messages)
                updatedChat = chat
            case .sent(_, let chat):
                strongSelf.customView.state = .sent(updatedMessages: chat.messages)
                updatedChat = chat
            }

            guard let delegate = self?.delegate else {
                return assertionFailure("Delegate should always exist at this point")
            }

            delegate.updated(chat: updatedChat)
        }
    }
}
