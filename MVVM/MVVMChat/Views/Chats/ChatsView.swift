//
//  ChatsView.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 13/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit
import Constraint

class ChatsView: UIView {

    private var chats = [ChatListItemViewModel]() {
        didSet {
            chatsTableView.reloadData()
        }
    }

    private lazy var chatsTableView: UITableView = {
        let chatsTableView = UITableView()
        chatsTableView.dataSource = self
        chatsTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        chatsTableView.tableFooterView = UIView(frame: CGRect.zero)
        chatsTableView.tableHeaderView = UIView(frame: CGRect.zero)
        chatsTableView.allowsSelection = true
        chatsTableView.allowsMultipleSelection = false
        addSubview(chatsTableView)
        return chatsTableView
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        addSubview(spinner)
        return spinner
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

    func display(viewModel: ChatListViewModel) {
        self.chats = viewModel.chats
        emptyMessage.isHidden = viewModel.hideEmptyMessage
        chatsTableView.isHidden = viewModel.hideChats
        switch viewModel.showSpinner {
        case true: spinner.startAnimating()
        case false: spinner.stopAnimating()
        }
    }

    private func setup() {
        addConstraints()
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
