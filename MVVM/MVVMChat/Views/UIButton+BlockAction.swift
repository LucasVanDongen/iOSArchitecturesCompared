//
//  UIButton+BlockAction.swift
//  LiveCore
//
//  Created by Lucas van Dongen on 20/03/2018.
//  Copyright © 2018 Hollywood.com. All rights reserved.
//

import UIKit

var actionBlockKey: UInt8 = 0

typealias BlockButtonActionBlock = (_ sender: UIButton) -> Void
private class ButtonActionBlockWrapper: NSObject {
    var block: BlockButtonActionBlock
    init(block: @escaping BlockButtonActionBlock) {
        self.block = block
    }
}

extension UIButton {

    public func action(for controlEvent: UIControlEvents, block: @escaping (UIButton) -> Void) {
        objc_setAssociatedObject(self,
                                 &actionBlockKey,
                                 ButtonActionBlockWrapper(block: block),
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.removeTarget(self, action: #selector(block_handleAction), for: controlEvent)
        addTarget(self, action: #selector(block_handleAction), for: controlEvent)
    }

    @objc
    fileprivate func block_handleAction(sender: UIButton) {
        guard let wrapper = objc_getAssociatedObject(self, &actionBlockKey) as? ButtonActionBlockWrapper else {
            return assertionFailure("Got an action I couldn't find a block for")
        }
        wrapper.block(sender)
    }

}
