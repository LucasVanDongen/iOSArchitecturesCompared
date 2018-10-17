//
//  CreateChatView.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 14/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class CreateChatView: UIView {

    private lazy var introduction: UILabel = {
        let introduction = UILabel()
        introduction.text = "Enter the name of the contact you want to start a new chat with:"
        introduction.font = UIFont.preferredFont(forTextStyle: .body)
        introduction.numberOfLines = 0
        addSubview(introduction)
        return introduction
    }()

    private lazy var contact: UITextField = {
        let contact = UITextField()
        contact.placeholder = "Contact"
        contact.clearButtonMode = .always
        contact.keyboardType = .alphabet
        contact.autocorrectionType = .no
        contact.autocapitalizationType = .words
        contact.spellCheckingType = .no
        contact.inputAccessoryView = createAccessoryView
        contact.returnKeyType = .continue
        addSubview(contact)
        return contact
    }()

    private lazy var createAccessoryView: BaseAccessoryView = {
        let width = UIApplication.shared.delegate?.window??.frame.size.width ?? 320
        let view = BaseAccessoryView(frame: CGRect(x: 0, y: 0, width: width, height: 46))
        view.backgroundColor = UIColor.groupTableViewBackground
        view.layoutIfNeeded()
        return view
    }()

    private lazy var create: ActionButton = {
        let create = ActionButton()
        create.setTitle("create", for: .normal)
        createAccessoryView.addSubview(create)
        return create
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        addSubview(spinner)
        return spinner
    }()

    private lazy var error: UILabel = {
        let error = UILabel()
        error.font = UIFont.preferredFont(forTextStyle: .footnote)
        error.textColor = UIColor.red
        error.isHidden = true
        addSubview(error)
        return error
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func display(viewModel: CreateChatViewModel) {
        create.action(for: .touchUpInside) { _ in
            viewModel.create(self.contact.text ?? "")
        }
        contact.returnAction { contact in
            viewModel.create(contact.text ?? "")
        }
        error.isHidden = viewModel.hideError
        create.isEnabled = viewModel.enableCreate
        switch viewModel.showSpinner {
        case true: spinner.startAnimating()
        case false: spinner.stopAnimating()
        }
    }

    private func setup() {
        addConstraints()
        create.addTarget(self, action: #selector(test), for: .touchUpInside)
        backgroundColor = UIColor.white
    }

    @objc
    private func test() {
        print("bla")
    }

    private func addConstraints() {
        introduction.attach(sides: [.top, .leading, .trailing], 8, respectingLayoutGuides: true)
        contact
            .attach(sides: [.leading, .trailing], 8)
            .space(8, .below, introduction)
        spinner.center()
        error
            .attach(sides: [.leading, .trailing], 8)
            .space(8, .below, contact)

        create.attach(sides: [.top, .bottom, .trailing], 3)
    }
}
