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
    case leading
    case bottom
    case trailing
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
    case trailing
    case above
    case leading

    var spacedViewAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .below: return .top
        case .leading: return .leading
        case .above: return .bottom
        case .trailing: return .trailing
        }
    }

    var otherViewAttribute: NSLayoutConstraint.Attribute {
        switch self {
        case .below: return .bottom
        case .trailing: return .trailing
        case .above: return .top
        case .leading: return .leading
        }
    }

    var side: Side {
        switch self {
        case .above: return .top
        case .leading: return .leading
        case .below: return .bottom
        case .trailing: return .trailing
        }
    }

    var layoutDirection: LayoutDirection {
        switch self {
        case .above, .below: return .vertically
        case .leading, .trailing: return .horizontally
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

    var attribute: NSLayoutConstraint.Attribute {
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

    var attributes: [NSLayoutConstraint.Attribute] {
        switch self {
        case .x: return [.centerX]
        case .y: return [.centerY]
        case .both: return [.centerX, .centerY]
        }
    }
}

public enum Side {
    case top
    case leading
    case bottom
    case trailing

    var attributes: (inAttribute: NSLayoutConstraint.Attribute, outAttribute: NSLayoutConstraint.Attribute) {
        switch self {
        case .top:
            return (.top, .bottom)
        case .leading:
            return (.leading, .bottom)
        case .bottom:
            return (.bottom, .top)
        case .trailing:
            return (.trailing, .leading)
        }
    }

    var attribute: NSLayoutConstraint.Attribute {
        switch self {
        case .top: return .top
        case .leading: return .leading
        case .bottom: return .bottom
        case .trailing: return .trailing
        }
    }

    var spaceDirection: SpaceDirection {
        switch self {
        case .top: return .above
        case .leading: return .leading
        case .bottom: return .below
        case .trailing: return .trailing
        }
    }

    var layoutDirection: LayoutDirection {
        switch self {
        case .bottom, .top: return .vertically
        case .leading, .trailing: return .horizontally
        }
    }
}

public enum Relation {
    case exactly
    case orLess
    case orMore

    var layoutRelation: NSLayoutConstraint.Relation {
        switch self {
        case .exactly:
            return .equal
        case .orLess:
            return .lessThanOrEqual
        case .orMore:
            return .greaterThanOrEqual
        }
    }

    var reversedLayoutRelation: NSLayoutConstraint.Relation {
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
