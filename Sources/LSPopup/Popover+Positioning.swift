//
//  Popover+Positioning.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 12/23/21.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
#if os(iOS)
import SwiftUI

/**
 Extensions for popover positioning.
 */
extension CGRect {
    /// The point at an anchor.
    /**

         topLeft              top              topRight
                X──────────────X──────────────X
                |                             |
                |                             |
         left   X            center           X   right
                |                             |
                |                             |
                X──────────────X──────────────X
         bottomLeft          bottom         bottomRight

     */
    func alignmentPoint(at anchor: Popover.Attributes.Position.Anchor) -> CGPoint {
        switch anchor {
        case .topLeft:
            return CGPoint(x: minX, y: minY)
        case .top:
            return CGPoint(x: center.x, y: minY)
        case .topRight:
            return CGPoint(x: maxX, y: minY)
        case .right:
            return CGPoint(x: maxX, y: center.y)
        case .bottomRight:
            return CGPoint(x: maxX, y: maxY)
        case .bottom:
            return CGPoint(x: center.x, y: maxY)
        case .bottomLeft:
            return CGPoint(x: minX, y: maxY)
        case .left:
            return CGPoint(x: minX, y: center.y)
        case .center:
            return CGPoint(x: center.x, y: center.y)
        }
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: minX + width * 0.5, y: minY + height * 0.5)
    }
}

#endif
