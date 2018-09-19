//
//  UIView+Constraint.swift
//  LiveCore
//
//  Created by Lucas van Dongen on 24/06/2018.
//  Copyright © 2018 Hollywood.com. All rights reserved.
//

import UIKit

extension UIView {

    @discardableResult
    @available(*, deprecated, renamed: "attach()", message: "Replaced by a simpler version of the function attach that does not ask for the parentView anymore")
    public func snap(inside parentView: UIView? = nil,
                     offset: CGFloat = 0) -> UIView {
        guard let parentView = parentView ?? superview else {
            assertionFailure("This view should either be added to a superview or have a parentView specified")
            return self
        }

        Constraint.snap(self, inside: parentView, offset: offset)
        return self
    }

    @discardableResult
    public func attach(offset: CGFloat = 0, respectingLayoutGuides: Bool = false) -> UIView {
        guard let superview = superview else {
            assertionFailure("This view should already have a superview")
            return self
        }

        Constraint.attach(self, inside: superview, offset: offset)
        return self
    }

    @discardableResult
    @available(*, deprecated, renamed: "attach()", message: "Replaced by a simpler version of the function attach that does not ask for the containingView anymore")
    public func attach(inside containingView: UIView,
                       top: Offsetable? = nil,
                       left: Offsetable? = nil,
                       bottom: Offsetable? = nil,
                       right: Offsetable? = nil) -> UIView {
        Constraint.attach(self,
                          inside: containingView,
                          top: top,
                          left: left,
                          bottom: bottom,
                          right: right)

        return self
    }

    @discardableResult
    public func attach(sides: Set<Side>,
                       _ offset: CGFloat = 0,
                       respectingLayoutGuides: Bool = false) -> UIView {
        var top: Offset? = nil
        var left: Offset? = nil
        var right: Offset? = nil
        var bottom: Offset? = nil

        func defaultOffset(with offset: CGFloat) -> Offset {
            return Offset(offset, .exactly, respectingLayoutGuide: respectingLayoutGuides)
        }

        sides.forEach { side in
            switch side {
            case .top:
                top = defaultOffset(with: offset)
            case .left:
                left = defaultOffset(with: offset)
            case .bottom:
                bottom = defaultOffset(with: offset)
            case .right:
                right = defaultOffset(with: offset)
            }
        }

        return attach(top: top, left: left, bottom: bottom, right: right)
    }

    @discardableResult
    public func attach(top: Offsetable? = nil,
                       left: Offsetable? = nil,
                       bottom: Offsetable? = nil,
                       right: Offsetable? = nil) -> UIView {
        guard top != nil || left != nil || bottom != nil || right != nil else {
            assertionFailure("At least one Offset should be specified")
            return self
        }

        guard let superview = superview else {
            assertionFailure("This view should already have a superview")
            return self
        }

        Constraint.attach(self,
                          inside: superview,
                          top: top,
                          left: left,
                          bottom: bottom,
                          right: right)

        return self
    }

    @discardableResult
    @available(*, deprecated, renamed: "center(axis:adjusted:priority:)", message: "Replaced by a simpler version of the function center that does not ask for the viewToCenterIn anymore")
    public func center(in viewToCenterIn: UIView? = nil,
                       axis: CenterAxis = .both,
                       adjusted: CGFloat = 0.0,
                       priority: UILayoutPriority = UILayoutPriority.required) -> UIView {
        let parentView: UIView
        if let viewToCenterIn = viewToCenterIn {
            parentView = viewToCenterIn
        } else {
            guard let superview = superview else {
                assertionFailure("You should either specify the containing view or have a superview set")
                return self
            }
            parentView = superview
        }
        Constraint.center(self, in: parentView, axis: axis, adjusted: adjusted, priority: priority)

        return self
    }

    @discardableResult
    public func center(axis: CenterAxis = .both,
                       adjusted: CGFloat = 0.0,
                       priority: UILayoutPriority = UILayoutPriority.required) -> UIView {
        guard let superview = superview else {
            assertionFailure("You should either specify the containing view or have a superview set")
            return self
        }

        Constraint.center(self, in: superview, axis: axis, adjusted: adjusted, priority: priority)

        return self
    }

    @discardableResult
    public func align(axis: CenterAxis,
                      to viewToAlignWith: UIView,
                      adjusted adjustment: CGFloat = 0.0,
                      priority: UILayoutPriority = .required) -> UIView {
        guard let superview = try? Constraint.determineSharedSuperview(between: self, and: viewToAlignWith) else {
            assertionFailure("These views should share a common superview")
            return self
        }

        let constraints = Constraint.align(self,
                                           axis,
                                           to: viewToAlignWith,
                                           adjusted: adjustment,
                                           priority: priority)

        superview.addConstraints(constraints)

        return self
    }

    @discardableResult
    public func space(_ distance: CGFloat,
                      _ direction: SpaceDirection,
                      _ view: UIView,
                      _ relation: Relation = .exactly,
                      priority: UILayoutPriority = UILayoutPriority.required) -> UIView {
        guard let superview = Constraint.determineSuperview(for: self, and: view) else {
            assertionFailure("These views should share a common superview")
            return self
        }

        let firstView: UIView
        let secondView: UIView
        switch direction {
        case .above, .leftOf:
            firstView = self
            secondView = view
        case .below, .rightOf:
            firstView = view
            secondView = self
        }

        let constraints = Constraint.space(firstView,
                                           secondView,
                                           inDirection: direction.layoutDirection,
                                           distance: distance,
                                           relation,
                                           priority: priority)
        superview.addConstraints(constraints)

        return self
    }

    @discardableResult
    public func align(_ side: Side,
                      _ distance: CGFloat = 0,
                      to viewToAlignTo: UIView) -> UIView {
        guard let constraintParent = try? Constraint.determineSharedSuperview(between: self, and: viewToAlignTo) else {
            assertionFailure("Should have a common parent")
            return self
        }

        constraintParent.addConstraint(Constraint.align(self, side, distance, to: viewToAlignTo))
        return self
    }

    @discardableResult
    public func align(_ sides: Set<Side>,
                      _ distance: CGFloat = 0,
                      to viewToAlignTo: UIView) -> UIView {
        guard let constraintParent = try? Constraint.determineSharedSuperview(between: self, and: viewToAlignTo) else {
            assertionFailure("Should have a common parent")
            return self
        }

        constraintParent.addConstraints(Constraint.align(self, sides, distance, to: viewToAlignTo))
        return self
    }

    @discardableResult
    public func ratio(_ ratio: CGSize,
                      _ relation: Relation = .exactly,
                      priority: UILayoutPriority = UILayoutPriority.required) -> UIView {
        addConstraint(Constraint.ratio(of: self, width: ratio.width, relatedToHeight: ratio.height))

        return self
    }

    @discardableResult
    public func ratio(of width: CGFloat,
                      to height: CGFloat = 1,
                      _ relation: Relation = .exactly,
                      priority: UILayoutPriority = UILayoutPriority.required) -> UIView {
        addConstraint(Constraint.ratio(of: self, width: width, relatedToHeight: height))

        return self
    }

    @discardableResult
    public func height(relatedTo otherView: UIView,
                       multiplied multiplier: CGFloat = 1.0,
                       adjusted adjustment: CGFloat = 0.0,
                       _ relation: Relation = .exactly) -> UIView {
        guard let viewToAddTo = try? Constraint.determineSharedSuperview(between: self, and: otherView) else {
            assertionFailure("They should share a node")
            return self
        }

        viewToAddTo.addConstraint(Constraint.height(of: self,
                                                    relatedTo: otherView,
                                                    multiplied: multiplier,
                                                    adjusted: adjustment,
                                                    relation))

        return self
    }

    @discardableResult
    public func width(relatedTo otherView: UIView,
                      multiplied multiplier: CGFloat = 1.0,
                      adjusted adjustment: CGFloat = 0.0,
                      _ relation: Relation = .exactly) -> UIView {
        guard let viewToAddTo = try? Constraint.determineSharedSuperview(between: self, and: otherView) else {
            assertionFailure("Either one of them should be the parent")
            return self
        }

        viewToAddTo.addConstraint(Constraint.width(of: self,
                                                   relatedTo: otherView,
                                                   multiplied: multiplier,
                                                   adjusted: adjustment,
                                                   relation))

        return self
    }

    @discardableResult
    public func size(_ size: CGSize,
                     widthRelation: Relation = .exactly,
                     heightRelation: Relation = .exactly) -> UIView {
        addConstraints([
            Constraint.width(size.width, widthRelation, for: self),
            Constraint.height(size.height, heightRelation, for: self)
            ])

        return self
    }

    @discardableResult
    public func size(width: CGFloat,
                     _ widthRelation: Relation = .exactly,
                     height: CGFloat,
                     _ heightRelation: Relation = .exactly) -> UIView {
        addConstraints([
            Constraint.width(width, widthRelation, for: self),
            Constraint.height(height, heightRelation, for: self)
            ])

        return self
    }

    @discardableResult
    public func width(_ width: CGFloat,
                      _ relation: Relation = .exactly,
                      priority: UILayoutPriority = UILayoutPriority.required) -> UIView {
        addConstraints([
            Constraint.width(width, relation, for: self, priority: priority)
            ])

        return self
    }

    @discardableResult
    public func height(_ height: CGFloat,
                       _ relation: Relation = .exactly,
                       priority: UILayoutPriority = UILayoutPriority.required) -> UIView {
        addConstraints([
            Constraint.height(height, relation, for: self, priority: priority)
            ])

        return self
    }

    public func animatableToastConstraint(fromThe side: Side,
                                          in view: UIView,
                                          using spacer: UIView) -> NSLayoutConstraint {
        switch side {
        case .bottom, .top:
            attach(left: 0, right: 0)
        case .left, .right:
            attach(top: 0, bottom: 0)
        }

        space(0, side.spaceDirection, spacer, priority: UILayoutPriority(700))

        let animatableConstraint = NSLayoutConstraint(item: self,
                                                      attribute: side.spaceDirection.otherViewAttribute,
                                                      relatedBy: .equal,
                                                      toItem: spacer,
                                                      attribute: side.spaceDirection.otherViewAttribute,
                                                      multiplier: 1,
                                                      constant: 0)
        animatableConstraint.priority = UILayoutPriority.defaultLow

        view.addConstraint(animatableConstraint)

        return animatableConstraint
    }
}
