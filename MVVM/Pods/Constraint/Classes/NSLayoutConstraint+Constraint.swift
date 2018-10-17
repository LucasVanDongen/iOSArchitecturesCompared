//
//  NSLayoutConstraint+Constraint.swift
//  Constraint
//
//  Created by Lucas van Dongen on 04/09/2018.
//

import UIKit

extension NSLayoutConstraint {
    public var activated: NSLayoutConstraint {
        isActive = true
        return self
    }

    public var deactivated: NSLayoutConstraint {
        isActive = false
        return self
    }
}
