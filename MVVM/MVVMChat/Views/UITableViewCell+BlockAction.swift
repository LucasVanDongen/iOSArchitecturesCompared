//
//  UITableViewCell.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 21/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

typealias BlockCellActionBlock = () -> Void
private class CellActionBlockWrapper: NSObject {
    var block: BlockCellActionBlock
    init(block: @escaping BlockCellActionBlock) {
        self.block = block
    }
}

extension UITableViewCell {
    public func tapAction(block: @escaping () -> Void) {
        objc_setAssociatedObject(self,
                                 &actionBlockKey,
                                 CellActionBlockWrapper(block: block),
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        gestureRecognizers = gestureRecognizers?.filter({ (recognizer) -> Bool in
            !(recognizer is UITapGestureRecognizer)
        })

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    private func cellTapped() {
        guard let wrapper = objc_getAssociatedObject(self, &actionBlockKey) as? CellActionBlockWrapper else {
            return assertionFailure("Got an action I couldn't find a block for")
        }

        wrapper.block()
    }
}
