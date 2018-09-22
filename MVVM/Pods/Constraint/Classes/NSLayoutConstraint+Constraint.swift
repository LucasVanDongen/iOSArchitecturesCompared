//
//  NSLayoutConstraint+Constraint.swift
//  Constraint
//
//  Created by Lucas van Dongen on 04/09/2018.
//

import UIKit

extension NSLayoutConstraint {
    var activated: NSLayoutConstraint {
        isActive = true
        return self
    }
}
