//
//  BaseAccessoryView.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 14/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class BaseAccessoryView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        autoresizingMask = .flexibleHeight
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: 46)
    }

}
