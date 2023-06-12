//
//  PopoverContainer.swift
//  LSPopup
//
//  Created by czi on 2023/6/5.
//

import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
public extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}



struct PopoverContainer: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.window) var ownWindow
    
    var body: some View {
        ZStack(alignment: .topLeading) {

            ForEach(viewModel.popovers) { popover in
                PopoverView(popover: popover)
                    .onDisappear {
                        popover.dismissAction?()
                        PopoverHolder.shared.removeContainer(with: viewModel)
                    }
                    .onAppear {
                        popover.show()
                    }
            }
            .frame(alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(white: 0, opacity: viewModel.bgOpacity))
        .edgesIgnoringSafeArea(.all)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                viewModel.pop()
            }
        }
        .opacity(viewModel.opacity)
        .onAppear {
            withAnimation(.easeInOut) {
                viewModel.opacity = 1.0
            }
        }
        
    }
}

struct PopoverView: View {
    var popover: Popover
    
    
    var body: some View {
        StateObjectView(viewModel: popover) {
            popover.view
                .cornerRadius(popover.attributes.cornerRadius)
                .shadow(color: popover.attributes.shadowColor, radius: popover.attributes.shadowRadius)
                .padding(popover.attributes.padding)
                .alignmentGuide(.leading) { -popover.alignmentOffset($0).width }
                .alignmentGuide(.top) { -popover.alignmentOffset($0).height }
                .scaleEffect(popover.readyShow ? 1 : 0.1, anchor: popover.attributes.scaleAnchor)
                .opacity(popover.readyShow ? 1 : 0)
                .animation(.easeInOut, value: popover.readyShow)
        }
    }
}

extension PopoverContainer {
    @MainActor final class ViewModel: ObservableObject {

        @Published private(set) var popovers: [Popover] = []
        @Published var opacity = 0.3
        
        private(set) var bgOpacity: Double
        init(bgOpacity: Double) {
            self.bgOpacity = bgOpacity
        }
        
        func present(with popover: Popover) {
            popovers.append(popover)
        }
        
        func dismiss(with popover: Popover) {
            withAnimation(.easeInOut) {
                
                popover.dismiss()
                if popovers.count == 1 {
                    opacity = 0
                }
            }
            withAnimation(.easeInOut.delay(0.1)) {
                popovers.removeAll(where: { $0 == popover })
            }
        }
        
        func pop() {
            guard let popover = popovers.last else {
                return
            }
            dismiss(with: popover)
        }
        
        func reload() {
            objectWillChange.send()
        }
    }
}

