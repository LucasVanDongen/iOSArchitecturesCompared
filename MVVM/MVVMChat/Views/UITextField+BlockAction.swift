//
//  UITextField+BlockAction.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 21/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

typealias BlockTextFieldActionBlock = (_ sender: UITextField) -> Void
private class TextFieldActionBlockWrapper: NSObject {
    var block: BlockTextFieldActionBlock
    init(block: @escaping BlockTextFieldActionBlock) {
        self.block = block
    }
}

extension UITextField {
    public func returnAction(block: @escaping (UITextField) -> Void) {
        objc_setAssociatedObject(self,
                                 &actionBlockKey,
                                 TextFieldActionBlockWrapper(block: block),
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        delegate = self
    }
}

extension UITextField: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let wrapper = objc_getAssociatedObject(self, &actionBlockKey) as? TextFieldActionBlockWrapper else {
            assertionFailure("Got an action I couldn't find a block for")
            return false
        }

        wrapper.block(textField)
        return true
    }
}
