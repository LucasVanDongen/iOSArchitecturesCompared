//
//  MessageTableViewCell.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 15/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell, IdentifiableCell {

    private lazy var bubble: MessageBubble = {
        let bubble = MessageBubble()
        contentView.addSubview(bubble)
        return bubble
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    func configure(with message: Message) {
        bubble.configure(with: message)
    }

    private func setup() {
        addConstraints()
    }

    private func addConstraints() {
        bubble.attach(to: self)
    }

}
