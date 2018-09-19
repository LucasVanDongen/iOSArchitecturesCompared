//
//  ChatsView.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 13/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit
import Constraint

protocol ChatsDelegate: class {
    func selected(chat: Chat)
}

class ChatsView: UIView {

    enum State {
        case empty
        case loading
        case loaded(chats: [Chat])
    }

    var state: State = .empty {
        didSet {
            let hideEmptyMessage: Bool
            let hideChats: Bool
            let chats: [Chat]

            switch state {
            case .empty:
                chats = []
                hideEmptyMessage = false
                hideChats = true
            case .loading:
                chats = []
                hideEmptyMessage = emptyMessage.isHidden
                hideChats = chatsTableView.isHidden
            case .loaded(let newChats):
                chats = newChats
                hideEmptyMessage = true
                hideChats = false
            }

            self.chats = chats
            emptyMessage.isHidden = hideEmptyMessage
            chatsTableView.isHidden = hideChats
            chatsTableView.reloadData()
        }
    }

    weak var delegate: ChatsDelegate?

    private var chats = [Chat]() {
        didSet {
            chatsTableView.reloadData()
        }
    }

    private lazy var chatsTableView: UITableView = {
        let chatsTableView = UITableView()
        chatsTableView.dataSource = self
        chatsTableView.delegate = self
        chatsTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        chatsTableView.tableFooterView = UIView(frame: CGRect.zero)
        chatsTableView.tableHeaderView = UIView(frame: CGRect.zero)
        chatsTableView.allowsSelection = true
        chatsTableView.allowsMultipleSelection = false
        addSubview(chatsTableView)
        return chatsTableView
    }()

    private lazy var emptyMessage: UILabel = {
        let emptyMessage = UILabel()
        emptyMessage.font = UIFont.preferredFont(forTextStyle: .headline)
        emptyMessage.text = "You don't have any conversations yet!"
        addSubview(emptyMessage)
        return emptyMessage
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addConstraints()
        state = .empty
        backgroundColor = UIColor.white
    }

    private func addConstraints() {
        chatsTableView.attach(sides: [.top, .left, .right, .bottom], respectingLayoutGuides: true)
        emptyMessage.attach(sides: [.top, .left, .right, .bottom], respectingLayoutGuides: true)
    }
}

extension ChatsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier,
                                                       for: indexPath) as? ChatTableViewCell,
            indexPath.row < chats.count else {
                return UITableViewCell()
        }

        cell.configure(with: chats[indexPath.row])
        return cell
    }
}

extension ChatsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < chats.count else {
            return assertionFailure(
                "We shouldn't be able to tap a row that lies outside of the bounds of the array of chats")
        }

        guard let chatsDelegate = delegate else {
            return assertionFailure("The ChatsDelegate should always be set by the ViewController")
        }

        let chat = chats[indexPath.row]
        chatsDelegate.selected(chat: chat)
    }
}
