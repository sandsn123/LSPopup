//
//  Position.swift
//  LSPopup
//
//  Created by czi on 2023/6/5.
//

import Foundation
import SwiftUI

extension Popover.Attributes {
    public enum Position {
        /**
         Attach the popover to a source view (supplied by the attributes' `sourceFrame` property).
         - parameter originAnchor: The corner of the source view used as the attaching point.
         - parameter popoverAnchor: The corner of the popover that attaches to the source view.
         */
        case absolute(originAnchor: Anchor, popoverAnchor: Anchor)
        
        /**
         Place the popover within a container view (supplied by the attributes' `sourcePoint` property).
         - parameter popoverAnchors: The corners of the container view that the popover can be placed. Supply multiple to get a picture-in-picture behavior..
         */
        case relative(sourcePoint: CGPoint, popoverAnchors: Anchor)
        
        /// The edges and corners of a rectangle.
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
        public enum Anchor {
            case topLeft
            case top
            case topRight
            case right
            case bottomRight
            case bottom
            case bottomLeft
            case left
            case center
        }
    }
    
    public enum Transition {
        case slide(x: CGFloat, y: CGFloat = 0)
        case scale
        case opacity
    }
}
