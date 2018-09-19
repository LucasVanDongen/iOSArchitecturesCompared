//
//  ChatView.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 15/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit
import Constraint

protocol ChatDelegate: class {
    func send(message: String)
}

class ChatView: UIView {

    enum State {
        case empty
        case sending(updatingMessages: [Message])
        case failed(reason: String)
        case sent(updatedMessages: [Message])
        case showing(messages: [Message])
    }

    var state: State = .empty {
        didSet {
            let hideEmptyText: Bool
            let enableSending: Bool
            switch state {
            case .empty:
                hideEmptyText = false
                enableSending = true
            case .sending(let messages):
                hideEmptyText = emptyText.isHidden
                enableSending = false
                self.messages = messages
            case .failed(let reason):
                hideEmptyText = emptyText.isHidden
                enableSending = true
                show(error: reason)
            case .sent(let messages):
                hideEmptyText = true
                enableSending = true
                self.messages = messages
            case .showing(let messages):
                hideEmptyText = true
                enableSending = true
                self.messages = messages
            }

            emptyText.isHidden = hideEmptyText
            sendMessage.isEnabled = enableSending
            switch enableSending {
            case true: spinner.stopAnimating()
            case false: spinner.startAnimating()
            }
        }
    }

    weak var delegate: ChatDelegate?
    private var isFirstLoad = true
    private var readMessages: [Message] = []
    private var messages: [Message] = [] {
        didSet(previousMessages) {
            guard !isFirstLoad else {
                isFirstLoad = false
                loadChangedData(between: previousMessages, and: messages, animated: false)
                return
            }

            loadChangedData(between: previousMessages, and: messages, animated: true)
        }
    }
    private var rowCount: Int = 0
    private var keyboardShowsConstraint: NSLayoutConstraint?

    private lazy var messageList: UITableView = {
        let messageList = UITableView()
        messageList.dataSource = self
        messageList.delegate = self
        messageList.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
        messageList.separatorStyle = .none
        messageList.tableFooterView = UIView(frame: CGRect.zero)
        messageList.tableHeaderView = UIView(frame: CGRect.zero)
        messageList.allowsSelection = false
        addSubview(messageList)
        return messageList
    }()

    private lazy var emptyText: UILabel = {
        let emptyText = UILabel()
        emptyText.font = UIFont.preferredFont(forTextStyle: .headline)
        emptyText.isHidden = true
        addSubview(emptyText)
        return emptyText
    }()

    private lazy var newMessageBlock: UIView = {
        let newMessageBlock = UIView()
        newMessageBlock.backgroundColor = .groupTableViewBackground
        addSubview(newMessageBlock)
        return newMessageBlock
    }()

    private lazy var message: UITextField = {
        let message = UITextField()
        message.placeholder = "Type your message"
        message.font = UIFont.preferredFont(forTextStyle: .body)
        message.delegate = self
        message.returnKeyType = .send
        newMessageBlock.addSubview(message)
        return message
    }()

    private lazy var sendMessage: ActionButton = {
        let sendMessage = ActionButton()
        sendMessage.setTitle("Send", for: .normal)
        newMessageBlock.addSubview(sendMessage)
        return sendMessage
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.hidesWhenStopped = true
        addSubview(spinner)
        return spinner
    }()

    private lazy var error: UILabel = {
        let error = UILabel()
        error.textColor = UIColor.red
        error.backgroundColor = UIColor.clear
        error.font = UIFont.preferredFont(forTextStyle: .footnote)
        error.alpha = 0
        addSubview(error)
        return error
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func configure(with messages: [Message]) {
        let newState: State
        switch messages.isEmpty {
        case true: newState = .empty
        case false: newState = .showing(messages: messages)
        }
        state = newState
    }

    @objc
    func send() {
        guard let delegate = delegate else {
            return assertionFailure("The delegate should always be set at this point")
        }

        delegate.send(message: message.text ?? "")
        message.text = nil
    }

    private func show(error: String) {
        self.error.alpha = 1
        self.error.text = error
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            UIView.animate(withDuration: 2, animations: {
                self?.error.alpha = 0
            })
        }
    }

    private func loadChangedData<T: Differentiable>(between previousValues: [T], and newValues: [T], animated: Bool) {
        let changedValues = TableViewDataDifferentiator.differentiate(oldValues: previousValues, with: newValues)
        let animation: UITableViewRowAnimation = animated ? .automatic : .none

        if !animated {
            UIView.setAnimationsEnabled(false)
        }

        messageList.performBatchUpdates({
            messageList.insertRows(at: changedValues.rowsToInsert, with: animation)
            messageList.reloadRows(at: changedValues.rowsToUpdate, with: .none)
            messageList.deleteRows(at: changedValues.rowsToDelete, with: animation)

            rowCount = newValues.count
        }, completion: { [weak self] (isCompleted) in
            guard isCompleted else {
                return
            }

            if !animated {
                UIView.setAnimationsEnabled(true)
            }

            guard let lastInsertedIndexPath = changedValues.rowsToInsert.last else {
                return
            }

            self?.scrollToLast(lastInsertedIndexPath: lastInsertedIndexPath, animated: animated)
        })
    }

    private func scrollToLast(lastInsertedIndexPath: IndexPath, animated: Bool) {
        let newRowWasInsertedAtBottom = lastInsertedIndexPath.row == messages.count - 1
        guard newRowWasInsertedAtBottom else {
            return
        }

        messageList.scrollToRow(at: lastInsertedIndexPath, at: .bottom, animated: animated)
    }

    private func setup() {
        addConstraints()
        addKeyboardListener()
        backgroundColor = UIColor.white
        messageList.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        sendMessage.addTarget(self, action: #selector(send), for: .touchUpInside)
    }

    private func addConstraints() {
        messageList
            .attach(sides: [.left, .right], respectingLayoutGuides: true)
            .attach(top: 0)
        newMessageBlock
            .attach(sides: [.left, .right])
            .space(0, .below, messageList)
            .height(46)
        error
            .attach(sides: [.left, .right], 8)
            .space(8, .above, newMessageBlock)
        message.attach(sides: [.top, .left, .bottom], 8)
        sendMessage
            .attach(sides: [.top, .bottom, .right], 3)
            .space(2, .rightOf, message)
            .setContentHuggingPriority(.required, for: .horizontal)
        spinner.align(axis: .both, to: sendMessage)

        keyboardShowsConstraint = Constraint.attach(newMessageBlock, inside: self,
                                                    bottom: 0.layoutGuideRespecting).first
        keyboardShowsConstraint?.isActive = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ChatView {
    private func addKeyboardListener() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeKeyboard(notification:)),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeKeyboard(notification:)),
                                               name: .UIKeyboardWillHide, object: nil)
    }

    @objc
    private func changeKeyboard(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
                return assertionFailure("Could not extract all needed information from the NSNotification")
        }

        let curveUintValue = UInt(UIViewAnimationCurve.easeInOut.rawValue)
        let animationOptions: UIViewAnimationOptions = [UIViewAnimationOptions(rawValue: curveUintValue)]
        let constant = -((UIApplication.shared.keyWindow?.frame.size.height ?? 0) - keyboardSize.origin.y)
        keyboardShowsConstraint?.constant = constant

        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
}

extension ChatView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier,
                                                       for: indexPath) as? MessageTableViewCell,
            indexPath.row < rowCount else {
                assertionFailure("Should have MessageTableViewCell for all cells")
                return UITableViewCell()
        }

        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }

}

extension ChatView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        message.endEditing(true)
    }
}

extension ChatView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        send()
        return true
    }
}
