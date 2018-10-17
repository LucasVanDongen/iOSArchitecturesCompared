//
//  ChatTableViewCell.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 13/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

protocol IdentifiableCell: class {
    static var identifier: String { get }
}

extension IdentifiableCell {
    static var identifier: String { return String(describing: self) }
}

class ChatTableViewCell: UITableViewCell, IdentifiableCell {
    private lazy var participant: UILabel = {
        let participant = UILabel()
        participant.font = UIFont.preferredFont(forTextStyle: .headline)
        participant.numberOfLines = 0
        contentView.addSubview(participant)
        return participant
    }()

    private lazy var lastMessage: UILabel = {
        let lastMessage = UILabel()
        lastMessage.font = UIFont.preferredFont(forTextStyle: .subheadline)
        lastMessage.numberOfLines = 0
        contentView.addSubview(lastMessage)
        return lastMessage
    }()

    private lazy var lastMessageDate: UILabel = {
        let lastMessageDate = UILabel()
        lastMessageDate.font = UIFont.preferredFont(forTextStyle: .footnote)
        lastMessageDate.numberOfLines = 1
        contentView.addSubview(lastMessageDate)
        return lastMessageDate
    }()

    private lazy var unreadMessageCounter: UILabel = {
        let unreadMessageCounter = UILabel()
        unreadMessageCounter.font = UIFont.preferredFont(forTextStyle: .body)
        unreadMessageCounter.textAlignment = .center
        unreadMessageCounter.backgroundColor = UIColor.red
        unreadMessageCounter.textColor = UIColor.white
        unreadMessageCounter.layer.cornerRadius = unreadMessageCounter.font.lineHeight / 2.0
        unreadMessageCounter.clipsToBounds = true
        contentView.addSubview(unreadMessageCounter)
        return unreadMessageCounter
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    func configure(with chat: ChatListItemViewModel) {
        participant.text = chat.contact
        lastMessage.text = chat.message
        lastMessageDate.text = chat.lastMessageDate
        show(unreadMessageCount: chat.unreadMessageCount)
        tapAction(block: chat.itemTapped)
    }

    private func setup() {
        addConstraints()
        selectionStyle = .none
    }

    private func addConstraints() {
        participant
            .attach(sides: [.top, .leading], 8)
        lastMessage
            .attach(leading: 8)
            .space(8, .below, participant)
        lastMessageDate
            .attach(sides: [.leading, .bottom], 8)
            .space(8, .below, lastMessage)
            .align(.trailing, to: lastMessage)
            .align(.trailing, to: participant)
        unreadMessageCounter
            .attach(trailing: 8)
            .center(axis: .y)
            .space(8, .trailing, lastMessageDate)
            .ratio(of: 1, to: 1, .orMore)
            .height(unreadMessageCounter.font.lineHeight)
            .setContentHuggingPriority(.required, for: .horizontal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        participant.text = nil
        lastMessage.text = nil
        lastMessageDate.text = nil
        show(unreadMessageCount: 0)
    }

    private func show(unreadMessageCount count: Int) {
        unreadMessageCounter.isHidden = count <= 0
        unreadMessageCounter.text = "\(count)"
    }
}
