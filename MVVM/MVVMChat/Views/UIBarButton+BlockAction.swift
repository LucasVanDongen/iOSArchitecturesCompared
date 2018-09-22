//
//  UIBarButton+BlockAction.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

typealias BlockBarButtonActionBlock = (_ sender: UIBarButtonItem) -> Void
private class BarButtonActionBlockWrapper: NSObject {
    var block: BlockBarButtonActionBlock
    init(block: @escaping BlockBarButtonActionBlock) {
        self.block = block
    }
}

extension UIBarButtonItem {
    public func action(block: @escaping (UIBarButtonItem) -> Void) {
        objc_setAssociatedObject(self,
                                 &actionBlockKey,
                                 BarButtonActionBlockWrapper(block: block),
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        self.action = #selector(block_handleAction(sender:))
        self.target = self
    }

    @objc
    fileprivate func block_handleAction(sender: UIBarButtonItem) {
        guard let wrapper = objc_getAssociatedObject(self, &actionBlockKey) as? BarButtonActionBlockWrapper else {
            return assertionFailure("Got an action I couldn't find a block for")
        }
        wrapper.block(sender)
    }
}
