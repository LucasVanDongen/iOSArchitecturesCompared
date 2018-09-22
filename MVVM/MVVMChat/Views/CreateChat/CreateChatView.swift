//
//  CreateChatView.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 14/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class CreateChatView: UIView {

    var state: CreateChatViewModel.State = .empty {
        didSet {
            let hideError: Bool
            let enableCreate: Bool
            let showSpinner: Bool

            switch state {
            case .empty:
                hideError = true
                enableCreate = true
                showSpinner = false
            case .creating:
                hideError = true
                enableCreate = false
                showSpinner = true
            case .failed(let error):
                hideError = false
                enableCreate = true
                showSpinner = false
                self.error.text = error
            }

            error.isHidden = hideError
            create.isEnabled = enableCreate
            switch showSpinner {
            case true: spinner.startAnimating()
            case false: spinner.stopAnimating()
            }
        }
    }

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
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
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

        state = viewModel.state
    }

    private func setup() {
        addConstraints()
        backgroundColor = UIColor.white
    }

    private func addConstraints() {
        introduction.attach(sides: [.top, .left, .right], 8, respectingLayoutGuides: true)
        contact
            .attach(sides: [.left, .right], 8)
            .space(8, .below, introduction)
        spinner.center()
        error
            .attach(sides: [.left, .right], 8)
            .space(8, .below, contact)

        create.attach(sides: [.top, .bottom, .right], 3)
    }
}
