//
//  Constraint+Retired.swift
//  LiveCore
//
//  Created by Lucas van Dongen on 24/06/2018.
//  Copyright © 2018 Hollywood.com. All rights reserved.
//

import UIKit

extension Constraint {

    class func animatableSlideInConstraint(for view: UIView,
                                           inside superView: UIView,
                                           fromThe side: Side) -> NSLayoutConstraint {
        clean(views: [view, superView])
        let attributes = side.attributes
        let outConstraint = NSLayoutConstraint(item: view,
                                               attribute: attributes.outAttribute,
                                               relatedBy: .equal,
                                               toItem: superView,
                                               attribute: attributes.inAttribute,
                                               multiplier: 1.0,
                                               constant: 0)
        outConstraint.priority = UILayoutPriority(rawValue: 799)
        let inConstraint = NSLayoutConstraint(item: view,
                                              attribute: attributes.inAttribute,
                                              relatedBy: .equal,
                                              toItem: superView,
                                              attribute: attributes.inAttribute,
                                              multiplier: 1.0,
                                              constant: 0)
        inConstraint.priority = UILayoutPriority(rawValue: 250)

        superView.addConstraints([inConstraint, outConstraint])

        return inConstraint
    }

}
