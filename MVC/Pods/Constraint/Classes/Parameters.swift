//
//  Parameters.swift
//  LiveCore
//
//  Created by Lucas van Dongen on 24/06/2018.
//  Copyright © 2018 Hollywood.com. All rights reserved.
//

import UIKit

public enum LayoutGuide {
    case none
    case top
    case left
    case bottom
    case right
    case horizontal
    case vertical
    case all
}

public protocol Offsetable {
    var offset: CGFloat { get }
    var relation: Relation { get }
    var respectingLayoutGuide: Bool { get }
    var priority: UILayoutPriority { get }
}

public protocol OffsetablePrimitive {
    var relation: Relation { get }
    var respectingLayoutGuide: Bool { get }
    var priority: UILayoutPriority { get }
}

extension OffsetablePrimitive {
    public var relation: Relation {
        return .exactly
    }

    public var respectingLayoutGuide: Bool {
        return false
    }

    public var priority: UILayoutPriority {
        return .required
    }
}

extension OffsetablePrimitive where Self: Offsetable {
}

extension Offsetable {
    public var layoutGuideRespecting: Offset {
        return Offset(offset, relation, respectingLayoutGuide: true, priority: priority)
    }

    public var defaultLowPrioritized: Offset {
        return Offset(offset,
                      relation,
                      respectingLayoutGuide: respectingLayoutGuide,
                      priority: UILayoutPriority.defaultLow)
    }

    public var defaultHighPrioritized: Offset {
        return Offset(offset,
                      relation,
                      respectingLayoutGuide: respectingLayoutGuide,
                      priority: UILayoutPriority.defaultHigh)
    }
    public var orMore: Offset {
        return Offset(offset,
                      .orMore,
                      respectingLayoutGuide: respectingLayoutGuide,
                      priority: priority)
    }

    public var orLess: Offset {
        return Offset(offset,
                      .orLess,
                      respectingLayoutGuide: respectingLayoutGuide,
                      priority: priority)
    }

    public func prioritized(to priority: UILayoutPriority) -> Offset {
        return Offset(offset,
                      relation,
                      respectingLayoutGuide: respectingLayoutGuide,
                      priority: priority)
    }
}

extension CGFloat: Offsetable, OffsetablePrimitive {
    public var offset: CGFloat {
        return self
    }
}

extension Int: Offsetable, OffsetablePrimitive {
    public var offset: CGFloat {
        return CGFloat(self)
    }
}

public struct Offset: Offsetable {
    public let offset: CGFloat
    public let relation: Relation
    public let respectingLayoutGuide: Bool
    public let priority: UILayoutPriority

    public init(_ offset: CGFloat,
                _ relation: Relation = .exactly,
                respectingLayoutGuide: Bool = false,
                priority: UILayoutPriority = .required) {
        self.offset = offset
        self.relation = relation
        self.respectingLayoutGuide = respectingLayoutGuide
        self.priority = priority
    }
}

public enum SpaceDirection {
    case below
    case rightOf
    case above
    case leftOf

    var spacedViewAttribute: NSLayoutAttribute {
        switch self {
        case .below: return .top
        case .rightOf: return .left
        case .above: return .bottom
        case .leftOf: return .right
        }
    }

    var otherViewAttribute: NSLayoutAttribute {
        switch self {
        case .below: return .bottom
        case .rightOf: return .right
        case .above: return .top
        case .leftOf: return .left
        }
    }

    var side: Side {
        switch self {
        case .above: return .top
        case .leftOf: return .left
        case .below: return .bottom
        case .rightOf: return .right
        }
    }

    var layoutDirection: LayoutDirection {
        switch self {
        case .above, .below: return .vertically
        case .leftOf, .rightOf: return .horizontally
        }
    }
}

public enum LayoutDirection {
    case vertically
    case horizontally
}

public enum AlignmentType {
    case leadingEdges
    case trailingEdges
    case topEdges
    case bottomEdges
    case horizontalCenters
    case verticalCenters
    case baselines

    var attribute: NSLayoutAttribute {
        switch self {
        case .leadingEdges: return .leading
        case .trailingEdges: return .trailing
        case .topEdges: return .top
        case .bottomEdges: return .bottom
        case .horizontalCenters: return .centerY
        case .verticalCenters: return .centerX
        case .baselines: return .lastBaseline
        }
    }
}

public enum CenterAxis {
    case x
    case y
    case both

    var attributes: [NSLayoutAttribute] {
        switch self {
        case .x: return [.centerX]
        case .y: return [.centerY]
        case .both: return [.centerX, .centerY]
        }
    }
}

public enum Side {
    case top
    case left
    case bottom
    case right

    var attributes: (inAttribute: NSLayoutAttribute, outAttribute: NSLayoutAttribute) {
        switch self {
        case .top:
            return (.top, .bottom)
        case .left:
            return (.left, .bottom)
        case .bottom:
            return (.bottom, .top)
        case .right:
            return (.right, .left)
        }
    }

    var attribute: NSLayoutAttribute {
        switch self {
        case .top: return .top
        case .left: return .left
        case .bottom: return .bottom
        case .right: return .right
        }
    }

    var spaceDirection: SpaceDirection {
        switch self {
        case .top: return .above
        case .left: return .leftOf
        case .bottom: return .below
        case .right: return .rightOf
        }
    }

    var layoutDirection: LayoutDirection {
        switch self {
        case .bottom, .top: return .vertically
        case .left, .right: return .horizontally
        }
    }
}

public enum Relation {
    case exactly
    case orLess
    case orMore

    var layoutRelation: NSLayoutRelation {
        switch self {
        case .exactly:
            return .equal
        case .orLess:
            return .lessThanOrEqual
        case .orMore:
            return .greaterThanOrEqual
        }
    }

    var reversedLayoutRelation: NSLayoutRelation {
        switch self {
        case .exactly:
            return .equal
        case .orLess:
            return .greaterThanOrEqual
        case .orMore:
            return .lessThanOrEqual
        }
    }
}
