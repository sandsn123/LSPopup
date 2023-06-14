//
//  File.swift
//  
//
//  Created by czi on 2023/6/12.
//

import SwiftUI

struct PopoverModifier: ViewModifier {
    var isPresented: Binding<Bool>
    @State private var sourceFrame: CGRect = .zero

    let buildAttributes: (inout Popover.Attributes) -> Void
    var view: () -> any View
    
    var dismissAction: (() -> Void)?
    
    @State private var popover: Popover?
    @State var window: UIWindow? = nil
    init(isPresented: Binding<Bool>, dismissAction: (() -> Void)? = nil,
         attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
         @ViewBuilder view: @escaping () -> any View) {
        
        self.isPresented = isPresented
        self.buildAttributes = buildAttributes
        self.view = view
        self.dismissAction = dismissAction
    }
    
    func body(content: Content) -> some View {
        content
            .onWindowChange($window)
            .frameReader(for: $sourceFrame)
            .onValueChange(of: isPresented.wrappedValue, { newValue in
                guard let window = window else {
                    return
                }
                
                if isPresented.wrappedValue {
                    var attributes = Popover.Attributes()
                    
                    if case .absolute = attributes.anchor {
                        attributes.sourceFrame = sourceFrame
                    } else {
                        attributes.sourceFrame = window.safeAreaLayoutGuide.layoutFrame
                    }
                    
                    buildAttributes(&attributes)

                    let popover = Popover(attributes: attributes, view: view)
                    popover.dismissAction = {
                        self.popover = nil
                        self.isPresented.wrappedValue = false
                        self.dismissAction?()
                    }
                    popover.present(in: window)
                    self.popover = popover
                } else {
                    guard let popover = popover else {
                        return
                    }
                    popover.dismiss(in: window)
                }
            })
    }
}

class PopoverHolder {
    class Weak<T>: NSObject where T: AnyObject {
        private(set) weak var pointee: T?

        var isPointeeDeallocated: Bool {
            pointee == nil
        }

        init(pointee: T) {
            self.pointee = pointee
        }
    }
    
    struct Container: Hashable {
        static func == (lhs: PopoverHolder.Container, rhs: PopoverHolder.Container) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        var id = UUID()
        let controller: UIViewController
        let viewModel: PopoverContainer.ViewModel
    }
    
    typealias WeakWindow = Weak<UIWindow>
    
    static let shared = PopoverHolder()
    
    private var windowModels: [WeakWindow : Container] = [:]
    
    @MainActor func present(in window: UIWindow, popover: Popover) {
        if let viewModel = existingPopoverModel(for: window)?.viewModel {
            viewModel.present(with: popover)
        } else {
            let viewModel = PopoverContainer.ViewModel()

            let swiftuiView = PopoverContainer().environmentObject(viewModel).environment(\.window, window)
            
            let controller = UIHostingController(rootView: swiftuiView)
            
            guard let containerView = controller.view else {
                return
            }
            
            containerView.backgroundColor = UIColor.clear
            window.addSubview(containerView)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                containerView.leftAnchor.constraint(equalTo: window.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: window.rightAnchor),
                containerView.topAnchor.constraint(equalTo: window.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
            
            let container = Container(controller: controller, viewModel: viewModel)
            let weakWindowReference = Weak(pointee: window)
            windowModels[weakWindowReference] = container
            
            viewModel.present(with: popover)
        }
    }
    
    @MainActor func dismiss(in window: UIWindow, popover: Popover) {
        guard let container = existingPopoverModel(for: window) else {
            return
        }
        
        container.viewModel.dismiss(with: popover)
    }
    
    @MainActor func removeContainer(with viewModel: PopoverContainer.ViewModel) {
        guard viewModel.popovers.isEmpty, let dict = windowModels.first(where: { holder, container in container.viewModel === viewModel }) else {
            return
        }
        dict.value.controller.view.removeFromSuperview()
        self.windowModels.removeValue(forKey: dict.key)
    }
    
    private func existingPopoverModel(for window: UIWindow) -> Container? {
        return windowModels.first(where: { holder, _ in holder.pointee === window })?.value
    }
}
