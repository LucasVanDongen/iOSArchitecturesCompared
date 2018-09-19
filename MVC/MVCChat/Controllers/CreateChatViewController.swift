//
//  CreateChatViewController.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 14/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class CreateChatViewController: UIViewController {

    private lazy var customView: CreateChatView = {
        let customView = CreateChatView()
        customView.delegate = self
        return customView
    }()

    weak var delegate: UpdatedChatDelegate?

    init(with delegate: UpdatedChatDelegate) {
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

        title = "Create Chat"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

}

extension CreateChatViewController: CreateChatDelegate {
    func createNewChat(for contact: String) {
        guard contact != "" else {
            customView.state = .failed(reason: "Please provide a contact name")
            return
        }

        customView.state = .creating
        ChatModelController.createChat(for: contact) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            guard let delegate = strongSelf.delegate else {
                return assertionFailure("The delegate should be set and not unloaded yet at this point")
            }

            let state: CreateChatView.State
            switch result {
            case .failed(let reason):
                state = .failed(reason: reason)
            case .reused(let existingChat):
                state = .empty
                strongSelf.push(to: existingChat, with: delegate)
            case .success(let newChat):
                state = .empty
                delegate.created(chat: newChat)
                strongSelf.push(to: newChat, with: delegate)
            }

            strongSelf.customView.state = state
        }
    }

    private func push(to chat: Chat, with delegate: UpdatedChatDelegate) {
        let chatViewController = ChatViewController(for: chat, with: delegate)
        BaseNavigationViewController.pushViewController(chatViewController,
                                                        animated: true,
                                                        removePreviousFromStack: true)
    }
}
