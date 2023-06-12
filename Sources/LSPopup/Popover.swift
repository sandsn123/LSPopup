//
//  Popover.swift
//  LSPopup
//
//  Created by czi on 2023/6/5.
//

import SwiftUI

public class Popover: Identifiable, Hashable, ObservableObject {
    
    public static func == (lhs: Popover, rhs: Popover) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public struct Attributes {
        var sourceFrame: CGRect
        public var anchor: Position

        public var padding: EdgeInsets
        public var cornerRadius: CGFloat = 8.0
        public var shadowRadius: CGFloat = 50
        public var shadowColor: Color = Color(.sRGBLinear, white: 0, opacity: 0.33)
        public var tapDismiss = true
        public var bgOpacity: Double = 0.2
        
        var scaleAnchor: UnitPoint = .center
        var transition: AnyTransition?
    
        public init(sourceFrame: CGRect = .zero, anchor: Position = .absolute(originAnchor: .center, popoverAnchor: .center), padding: EdgeInsets = .init()) {
            self.sourceFrame = sourceFrame
            self.anchor = anchor
            self.padding = padding
        }
    }
    
    public var id = UUID()
    public var attributes: Attributes
    var view: AnyView
    var dismissAction: (() -> Void)?

    @Published public private(set) var readyShow = false
    
    public init(
        attributes: Attributes = .init(),
        @ViewBuilder view: @escaping () -> any View
    ) {
        
        self.attributes = attributes
        self.view = AnyView(view())
        caculateScaleEffectAnchor()
    }
    

    func alignmentOffset(_ dm: ViewDimensions) -> CGSize {
        switch attributes.anchor {
        case .absolute(let originAnchor, let popoverAnchor):
            let point = attributes.sourceFrame.alignmentPoint(at: originAnchor)
            switch popoverAnchor {
            case .topLeft:
                return CGSize(width: point.x, height: point.y)
            case .top:
                return CGSize(width: point.x-dm.width*0.5, height: point.y)
            case .topRight:
                return CGSize(width: point.x-dm.width, height: point.y)
            case .right:
                return CGSize(width: point.x-dm.width, height: point.y-dm.height*0.5)
            case .bottomRight:
                return CGSize(width: point.x-dm.width, height: point.y-dm.height)
            case .bottom:
                return CGSize(width: point.x-dm.width*0.5, height: point.y-dm.height)
            case .bottomLeft:
                return CGSize(width: point.x, height: point.y-dm.height)
            case .left:
                return CGSize(width: point.x, height: point.y-dm.height*0.5)
            case .center:
                return CGSize(width: point.x-dm.width*0.5, height: point.y-dm.height*0.5)
            }

        case .relative(let point, let popoverAnchor):
            switch popoverAnchor {
            case .topLeft:
                return CGSize(width: point.x, height: point.y)
            case .top:
                return CGSize(width: point.x-dm.width*0.5, height: point.y)
            case .topRight:
                return CGSize(width: point.x-dm.width, height: point.y)
            case .right:
                return CGSize(width: point.x-dm.width, height: point.y-dm.height*0.5)
            case .bottomRight:
                return CGSize(width: point.x-dm.width, height: point.y-dm.height)
            case .bottom:
                return CGSize(width: point.x-dm.width*0.5, height: point.y-dm.height)
            case .bottomLeft:
                return CGSize(width: point.x, height: point.y-dm.height)
            case .left:
                return CGSize(width: point.x, height: point.y-dm.height*0.5)
            case .center:
                return CGSize(width: point.x-dm.width*0.5, height: point.y-dm.height*0.5)
            }
        }
    }
    
    func caculateScaleEffectAnchor() {
        switch attributes.anchor {
        case .absolute(_, let popoverAnchor):
            switch popoverAnchor {
            case .bottom:
                attributes.scaleAnchor = .bottom
            case .bottomLeft:
                attributes.scaleAnchor =  .bottomLeading
            case .bottomRight:
                attributes.scaleAnchor =  .bottomTrailing
            case .top:
                attributes.scaleAnchor =  .top
            case .topLeft:
                attributes.scaleAnchor =  .topLeading
            case .topRight:
                attributes.scaleAnchor =  .topTrailing
            case .left:
                attributes.scaleAnchor =  .leading
            case .right:
                attributes.scaleAnchor =  .trailing
            case .center:
                attributes.scaleAnchor =  .center
            }
        case .relative(_, let popoverAnchor):
            switch popoverAnchor {
            case .bottom:
                attributes.scaleAnchor = .bottom
            case .bottomLeft:
                attributes.scaleAnchor =  .bottomLeading
            case .bottomRight:
                attributes.scaleAnchor =  .bottomTrailing
            case .top:
                attributes.scaleAnchor =  .top
            case .topLeft:
                attributes.scaleAnchor =  .topLeading
            case .topRight:
                attributes.scaleAnchor =  .topTrailing
            case .left:
                attributes.scaleAnchor =  .leading
            case .right:
                attributes.scaleAnchor =  .trailing
            case .center:
                attributes.scaleAnchor =  .center
            }
        }
    }
    
    @MainActor func show() {
        readyShow = true
    }
    
    @MainActor func dismiss() {
        readyShow = false
    }
}

extension Popover {
    /**
     Present a popover in a window. It may be easier to use the `UIViewController.present(_:)` convenience method instead.
     */
    @MainActor func present(in window: UIWindow) {
        PopoverHolder.shared.present(in: window, popover: self)
    }
    
    /**
     Dismiss a popover.
     
     - parameter transaction: An optional transaction that can be applied for the dismissal animation.
     */
    @MainActor func dismiss(in window: UIWindow) {
        PopoverHolder.shared.dismiss(in: window, popover: self)
    }
}
