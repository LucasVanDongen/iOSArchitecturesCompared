//
//  Constraint.swift
//
//  Created by Lucas van Dongen on 5/30/17.
//  Copyright © 2017 Lucas van Dongen. All rights reserved.
//

import UIKit

public class Constraint {
    static let excludedViewClasses = ["UITableViewCellContentView"]
    static let excludedParentViewClasses = ["UIViewControllerWrapperView"]

    public class func align(_ viewToAlign: UIView,
                            _ axis: CenterAxis,
                            to viewToAlignTo: UIView,
                            adjusted adjustment: CGFloat = 0.0,
                            priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        clean(views: [viewToAlign, viewToAlignTo])
        return axis.attributes.map { attribute in
            let constraint = NSLayoutConstraint(item: viewToAlign,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: viewToAlignTo,
                                                attribute: attribute,
                                                multiplier: 1.0,
                                                constant: adjustment)
            constraint.priority = priority
            return constraint
        }
    }

    public class func align(_ viewToAlign: UIView,
                            _ side: Side,
                            _ distance: CGFloat = 0,
                            relation: NSLayoutRelation = .equal,
                            to viewToAlignTo: UIView) -> NSLayoutConstraint {
        clean(views: [viewToAlign, viewToAlignTo])
        return NSLayoutConstraint(item: viewToAlign,
                                  attribute: side.attribute,
                                  relatedBy: relation,
                                  toItem: viewToAlignTo,
                                  attribute: side.attribute,
                                  multiplier: 1,
                                  constant: distance)
    }

    public class func align(_ viewToAlign: UIView,
                            _ sides: Set<Side>,
                            _ distance: CGFloat = 0,
                            relation: NSLayoutRelation = .equal,
                            to viewToAlignTo: UIView) -> [NSLayoutConstraint] {
        clean(views: [viewToAlign, viewToAlignTo])
        return sides.map { side -> NSLayoutConstraint in
            NSLayoutConstraint(item: viewToAlign,
                               attribute: side.attribute,
                               relatedBy: relation,
                               toItem: viewToAlignTo,
                               attribute: side.attribute,
                               multiplier: 1,
                               constant: distance)
        }
    }

    public class func center(_ viewToCenter: UIView,
                             in viewToCenterTo: UIView,
                             axis: CenterAxis = .both,
                             adjusted: CGFloat = 0.0,
                             priority: UILayoutPriority = UILayoutPriority.required) {
        clean(views: [viewToCenter, viewToCenterTo])

        if axis != .y {
            let alignXConstraint = NSLayoutConstraint(item: viewToCenter,
                                                      attribute: .centerX,
                                                      relatedBy: .equal,
                                                      toItem: viewToCenterTo,
                                                      attribute: .centerX,
                                                      multiplier: 1.0,
                                                      constant: adjusted)
            alignXConstraint.priority = priority
            viewToCenterTo.addConstraint(alignXConstraint)
        }

        if axis != .x {
            let alignYConstraint = NSLayoutConstraint(item: viewToCenter,
                                                      attribute: .centerY,
                                                      relatedBy: .equal,
                                                      toItem: viewToCenterTo,
                                                      attribute: .centerY,
                                                      multiplier: 1.0,
                                                      constant: adjusted)
            alignYConstraint.priority = priority
            viewToCenterTo.addConstraint(alignYConstraint)
        }
    }

    public class func height(_ size: CGFloat,
                             _ relation: Relation = .exactly,
                             for view: UIView,
                             priority: UILayoutPriority = UILayoutPriority.required) -> NSLayoutConstraint {
        clean(views: [view])
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .height,
                                            relatedBy: relation.layoutRelation,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: size)

        constraint.priority = priority

        return constraint
    }

    public class func width(of view: UIView,
                            theSame relation: Relation = .exactly,
                            than otherView: UIView,
                            multipliedBy multiplier: CGFloat = 1.0,
                            priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .width,
                                            relatedBy: relation.layoutRelation,
                                            toItem: otherView,
                                            attribute: .width,
                                            multiplier: multiplier,
                                            constant: 0.0)
        constraint.priority = priority
        return constraint
    }

    public class func width(_ size: CGFloat,
                            _ relation: Relation = .exactly,
                            for view: UIView,
                            priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        clean(views: [view])
        let constraint = NSLayoutConstraint(item: view,
                                            attribute: .width,
                                            relatedBy: relation.layoutRelation,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: size)

        constraint.priority = priority

        return constraint
    }

    public class func width(of view: UIView,
                            relatedTo otherView: UIView,
                            multiplied multiplier: CGFloat = 1.0,
                            priority: UILayoutPriority = .required,
                            adjusted adjustment: CGFloat = 0.0,
                            _ relation: Relation = .exactly) -> NSLayoutConstraint {
        let parentView = otherView
        let childView = view

        clean(views: [view, otherView])
        let width = NSLayoutConstraint(item: childView,
                                       attribute: .width,
                                       relatedBy: relation.layoutRelation,
                                       toItem: parentView,
                                       attribute: .width,
                                       multiplier: multiplier,
                                       constant: adjustment)
        width.priority = priority
        return width
    }

    public class func height(of view: UIView,
                             relatedTo otherView: UIView,
                             multiplied multiplier: CGFloat = 1.0,
                             priority: UILayoutPriority = .required,
                             adjusted adjustment: CGFloat = 0.0,
                             _ relation: Relation = .exactly) -> NSLayoutConstraint {
        clean(views: [view, otherView])
        let height = NSLayoutConstraint(item: view,
                                        attribute: .height,
                                        relatedBy: relation.layoutRelation,
                                        toItem: otherView,
                                        attribute: .height,
                                        multiplier: multiplier,
                                        constant: adjustment)
        height.priority = priority
        return height
    }

    public class func ratio(of view: UIView,
                            width: CGFloat,
                            _ relation: NSLayoutRelation = .equal,
                            relatedToHeight height: CGFloat) -> NSLayoutConstraint {
        let multiplier = width / height
        clean(views: [view])
        return NSLayoutConstraint(item: view,
                                  attribute: .width,
                                  relatedBy: relation,
                                  toItem: view,
                                  attribute: .height,
                                  multiplier: multiplier,
                                  constant: 0)
    }

    @available(*, deprecated, renamed: "attach", message: "Replaced by attach")
    public class func snap(_ view: UIView,
                           inside containingView: UIView,
                           offset: CGFloat = 0) {
        attach(view, inside: containingView, offset: offset)
    }

    @discardableResult
    public class func attach(_ view: UIView,
                           inside containingView: UIView,
                           offset: CGFloat = 0) -> [NSLayoutConstraint] {
        return attach(view,
                      inside: containingView,
                      top: offset,
                      left: offset,
                      bottom: offset,
                      right: offset)
    }

    @discardableResult
    public class func attach(_ view: UIView,
                             inside containingView: UIView,
                             top: Offsetable? = nil,
                             left: Offsetable? = nil,
                             bottom: Offsetable? = nil,
                             right: Offsetable? = nil) -> [NSLayoutConstraint] {
        clean(views: [view, containingView])
        var constraints = [NSLayoutConstraint]()

        if let top = top {
            let topConstraint: NSLayoutConstraint
            let margins = top.respectingLayoutGuide ? containingView.layoutMarginsGuide.topAnchor :
                containingView.topAnchor
            switch top.relation {
            case .exactly:
                topConstraint = view.topAnchor.constraint(equalTo: margins, constant: top.offset)
            case .orLess:
                topConstraint = view.topAnchor.constraint(lessThanOrEqualTo: margins, constant: top.offset)
            case .orMore:
                topConstraint = view.topAnchor.constraint(greaterThanOrEqualTo: margins, constant: top.offset)
            }
            topConstraint.priority = top.priority
            constraints.append(topConstraint)
        }

        if let left = left {
            let leftConstraint = NSLayoutConstraint(item: view,
                                                    attribute: .left,
                                                    relatedBy: left.relation.layoutRelation,
                                                    toItem: containingView,
                                                    attribute: .left,
                                                    multiplier: 1,
                                                    constant: left.offset)
            leftConstraint.priority = left.priority
            constraints.append(leftConstraint)
        }

        if let bottom = bottom {
            let bottomConstraint: NSLayoutConstraint
            switch bottom.respectingLayoutGuide {
            case true:
                let margins = containingView.layoutMarginsGuide
                bottomConstraint = view.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -bottom.offset)
            case false:
                bottomConstraint = NSLayoutConstraint(item: view,
                                                      attribute: .bottom,
                                                      relatedBy: bottom.relation.layoutRelation,
                                                      toItem: containingView,
                                                      attribute: .bottom,
                                                      multiplier: 1,
                                                      constant: -bottom.offset)
            }
            bottomConstraint.priority = bottom.priority
            constraints.append(bottomConstraint)
        }

        if let right = right {
            let rightConstraint = NSLayoutConstraint(item: view,
                                                     attribute: .right,
                                                     relatedBy: right.relation.layoutRelation,
                                                     toItem: containingView,
                                                     attribute: .right,
                                                     multiplier: 1,
                                                     constant: -right.offset)
            rightConstraint.priority = right.priority
            constraints.append(rightConstraint)
        }

        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    public class func space(_ views: UIView...,
        inDirection direction: LayoutDirection,
        distance: CGFloat = 0,
        _ relation: Relation = .exactly,
        priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        clean(views: views)
        let firstViewAttribute: NSLayoutAttribute = direction == .horizontally ? .right : .bottom
        let secondViewAttribute: NSLayoutAttribute = direction == .horizontally ? .left : .top

        return views.compactMap({ (view: UIView) -> (UIView, Int)? in
            guard let index = views.index(of: view) else {
                return nil
            }
            return (view, index)
        }).compactMap({ (view: UIView, index: Int) -> (UIView, Int)? in
            return index + 1 < views.count ? (view, index + 1) : nil
        }).map({ (view: UIView, nextIndex: Int) -> NSLayoutConstraint in
            let nextView = views[nextIndex]
            return NSLayoutConstraint(item: view,
                                      attribute: firstViewAttribute,
                                      relatedBy: relation.layoutRelation,
                                      toItem: nextView,
                                      attribute: secondViewAttribute,
                                      multiplier: 1,
                                      constant: -distance)
        }).map({ (constraint: NSLayoutConstraint) -> NSLayoutConstraint in
            constraint.priority = priority
            return constraint
        })
    }
}
