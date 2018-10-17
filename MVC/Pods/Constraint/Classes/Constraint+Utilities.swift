//
//  Constraint+Utilities.swift
//  LiveCore
//
//  Created by Lucas van Dongen on 24/06/2018.
//  Copyright © 2018 Hollywood.com. All rights reserved.
//

import UIKit

extension Constraint {

    class func clean(views: [UIView]) {
        views.forEach({ view in
            guard !isBaseView(view) else {
                return
            }

            view.translatesAutoresizingMaskIntoConstraints = false
        })
    }

    class func isBaseView(_ view: UIView) -> Bool {
        let classString = String(describing: type(of: view))

        if excludedViewClasses.contains(classString) {
            return true
        }

        // Hack
        if view is UICollectionViewCell {
            return true
        }

        guard let superview = view.superview else {
            return true
        }

        let superviewClassString = String(describing: type(of: superview))
        let superviewIsExcluded = excludedParentViewClasses.contains(superviewClassString)

        // Hack
        if superview is UICollectionViewCell {
            return true
        }

        return superviewIsExcluded
    }

    static func determineSuperview(for view1: UIView, and view2: UIView) -> UIView? {
        if view1.superview === view2 {
            return view1.superview
        }

        if view2.superview === view1 {
            return view2.superview
        }

        if view1.superview === view2.superview && view1.superview != nil {
            return view1.superview
        }

        return nil
    }

    enum ParentChildError: Error {
        case neitherIsParent
        case doNotShareNode
    }

    static func determineParentChildView(from oneView: UIView,
                                         and anotherView: UIView) throws -> (parentView: UIView, childView: UIView) {
        let otherViewContainsThisView = anotherView.subviews.contains(oneView)
        let thisViewContainsOtherView = oneView.subviews.contains(anotherView)

        guard otherViewContainsThisView || thisViewContainsOtherView else {
            throw ParentChildError.neitherIsParent
        }

        let parentView = otherViewContainsThisView ? anotherView : oneView
        let childView = otherViewContainsThisView ? oneView : anotherView

        return (parentView: parentView, childView: childView)
    }

    static func viewHierarchy(for view: UIView) -> [UIView] {
        var views: [UIView] = [view]

        if let superview = view.superview {
            views.append(contentsOf: viewHierarchy(for: superview))
        }

        return views
    }

    public static func determineSharedSuperview(between oneView: UIView, and anotherView: UIView) throws -> UIView {
        let oneViewStack = viewHierarchy(for: oneView)
        let anotherViewStack = viewHierarchy(for: anotherView)
        let sharedViews = oneViewStack.filter(anotherViewStack.contains)
        guard let firstSharedView = sharedViews.first else {
            throw ParentChildError.doNotShareNode
        }

        return firstSharedView
    }
/*
    class func anchorConstraint(of view: UIView,
                                inside containingView: UIView,
                                fromThe side: Side,
                                _ relation: Relation = .exactly,
                                withPriority priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let guide = containingView.safeAreaLayoutGuide
        var constraint: NSLayoutConstraint
        switch side {
        case .top:
            let anchor = guide.topAnchor
            let otherAnchor = guide.topAnchor
            switch relation {
            case .orLess:
                constraint = anchor.constraintLessThanOrEqualToSystemSpacingBelow(otherAnchor,
                                                                                  multiplier: 1.0)
            case .exactly:
                constraint = anchor.constraintEqualToSystemSpacingBelow(otherAnchor,
                                                                        multiplier: 1.0)
            case .orMore:
                constraint = anchor.constraintGreaterThanOrEqualToSystemSpacingBelow(otherAnchor,
                                                                                     multiplier: 1.0)
            }
        case .left:
            let anchor = view.leftAnchor
            let otherAnchor = guide.leftAnchor
            switch relation {
            case .orLess:
                constraint = anchor.constraintLessThanOrEqualToSystemSpacingAfter(otherAnchor,
                                                                                  multiplier: 1.0)
            case .exactly:
                constraint = anchor.constraintEqualToSystemSpacingAfter(otherAnchor,
                                                                        multiplier: 1.0)
            case .orMore:
                constraint = anchor.constraintGreaterThanOrEqualToSystemSpacingAfter(otherAnchor,
                                                                                     multiplier: 1.0)
            }
        case .bottom:
            let anchor = view.bottomAnchor
            let otherAnchor = guide.bottomAnchor
            switch relation {
            case .orLess:
                constraint = anchor.constraintLessThanOrEqualToSystemSpacingBelow(otherAnchor,
                                                                                  multiplier: 1.0)
            case .exactly:
                constraint = anchor.constraintEqualToSystemSpacingBelow(otherAnchor,
                                                                        multiplier: 1.0)
            case .orMore:
                constraint = anchor.constraintGreaterThanOrEqualToSystemSpacingBelow(otherAnchor,
                                                                                     multiplier: 1.0)
            }
        case .right:
            let anchor = guide.rightAnchor
            let otherAnchor = view.rightAnchor
            switch relation {
            case .orLess:
                constraint = anchor.constraintLessThanOrEqualToSystemSpacingAfter(otherAnchor,
                                                                                  multiplier: 1.0)
            case .exactly:
                constraint = anchor.constraintEqualToSystemSpacingAfter(otherAnchor,
                                                                        multiplier: 1.0)
            case .orMore:
                constraint = anchor.constraintGreaterThanOrEqualToSystemSpacingAfter(otherAnchor,
                                                                                     multiplier: 1.0)
            }
        }

        constraint.priority = priority
        return constraint
    }*/
}
