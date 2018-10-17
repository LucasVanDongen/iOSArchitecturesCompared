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
                            relation: NSLayoutConstraint.Relation = .equal,
                            to viewToAlignTo: UIView,
                            priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        clean(views: [viewToAlign, viewToAlignTo])
        let constraint = NSLayoutConstraint(item: viewToAlign,
                                            attribute: side.attribute,
                                            relatedBy: relation,
                                            toItem: viewToAlignTo,
                                            attribute: side.attribute,
                                            multiplier: 1,
                                            constant: distance)
        constraint.priority = priority
        return constraint
    }

    public class func align(_ viewToAlign: UIView,
                            _ sides: Set<Side>,
                            _ distance: CGFloat = 0,
                            relation: NSLayoutConstraint.Relation = .equal,
                            to viewToAlignTo: UIView,
                            priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        clean(views: [viewToAlign, viewToAlignTo])
        return sides.map { side -> NSLayoutConstraint in
            let constraint = NSLayoutConstraint(item: viewToAlign,
                                                attribute: side.attribute,
                                                relatedBy: relation,
                                                toItem: viewToAlignTo,
                                                attribute: side.attribute,
                                                multiplier: 1,
                                                constant: distance)
            constraint.priority = priority
            return constraint
        }
    }

    public class func center(_ viewToCenter: UIView,
                             in viewToCenterTo: UIView,
                             axis: CenterAxis = .both,
                             adjusted: CGFloat = 0.0,
                             priority: UILayoutPriority = .required) {
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
                             priority: UILayoutPriority = .required) -> NSLayoutConstraint {
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
                            _ relation: NSLayoutConstraint.Relation = .equal,
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
                             offset: CGFloat = 0,
                             respectingLayoutGuides: Bool = false) -> [NSLayoutConstraint] {
        return attach(view,
                      inside: containingView,
                      top: offset.layoutGuideRespecting,
                      leading: offset.layoutGuideRespecting,
                      bottom: offset.layoutGuideRespecting,
                      trailing: offset.layoutGuideRespecting)
    }

    @discardableResult
    @available(*, deprecated, renamed: "attach(_:inside:top:leading:bottom:trailing:)", message: "Replaced by leading and trailing variant")
    public class func attach(_ view: UIView,
                             inside containingView: UIView,
                             top: Offsetable? = nil,
                             left: Offsetable? = nil,
                             bottom: Offsetable? = nil,
                             right: Offsetable? = nil) -> [NSLayoutConstraint] {
        return attach(view, inside: containingView, top: top, leading: left, bottom: bottom, trailing: right)

    }

    @discardableResult
    public class func attach(_ view: UIView,
                             inside containingView: UIView,
                             top: Offsetable? = nil,
                             leading: Offsetable? = nil,
                             bottom: Offsetable? = nil,
                             trailing: Offsetable? = nil) -> [NSLayoutConstraint] {
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

        if let leading = leading {
            let leadingConstraint = NSLayoutConstraint(item: view,
                                                       attribute: .leading,
                                                       relatedBy: leading.relation.layoutRelation,
                                                       toItem: containingView,
                                                       attribute: .leading,
                                                       multiplier: 1,
                                                       constant: leading.offset)
            leadingConstraint.priority = leading.priority
            constraints.append(leadingConstraint)
        }

        if let bottom = bottom {
            let bottomConstraint: NSLayoutConstraint
            let margins = bottom.respectingLayoutGuide ? containingView.layoutMarginsGuide.bottomAnchor :
                containingView.bottomAnchor
            switch bottom.relation {
            case .exactly:
                bottomConstraint = view.bottomAnchor.constraint(equalTo: margins, constant: -bottom.offset)
            case .orLess:
                bottomConstraint = view.bottomAnchor.constraint(lessThanOrEqualTo: margins, constant: -bottom.offset)
            case .orMore:
                bottomConstraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: margins, constant: -bottom.offset)
            }
            bottomConstraint.priority = bottom.priority
            constraints.append(bottomConstraint)
        }

        if let trailing = trailing {
            let trailingConstraint = NSLayoutConstraint(item: view,
                                                        attribute: .trailing,
                                                        relatedBy: trailing.relation.layoutRelation,
                                                        toItem: containingView,
                                                        attribute: .trailing,
                                                        multiplier: 1,
                                                        constant: -trailing.offset)
            trailingConstraint.priority = trailing.priority
            constraints.append(trailingConstraint)
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
        let firstViewAttribute: NSLayoutConstraint.Attribute = direction == .horizontally ? .trailing : .bottom
        let secondViewAttribute: NSLayoutConstraint.Attribute = direction == .horizontally ? .leading : .top

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
