//
//  ChatsViewController.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 11/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {

    private lazy var customView: ChatsView = {
        let customView = ChatsView()
        return customView
    }()

    private var addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ChatEventHandler.add(listener: self)
        title = "Chats"
        DispatchQueue.global().async {
            ChatEventRouter.route(event: .applicationInitialized)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItem = nil
    }
}

extension ChatsViewController: ChatListListening {
    func updated(list: ChatListViewModel) {
        addButton.action(block: { _ in
            list.addChat()
        })
        customView.display(viewModel: list)
    }
}
