//
//  PopoverContainer.swift
//  LSPopup
//
//  Created by czi on 2023/6/5.
//

import SwiftUI

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
        .animation(.easeInOut, value: viewModel.opacity)
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
                .withTransition(popover)
                .eraseToAnyView()
        }
    }
    
}

// A View wrapper to make the modifier easier to use
private extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(erasing: self)
    }
    
    func buildView(_ transition: Popover.Attributes.Transition, popover: Popover) -> any View {
        switch transition {
        case .slide(let x, let y):
            return offset(x: popover.readyShow ? 0 : x, y: popover.readyShow ? 0 : y).animation(.linear, value: popover.readyShow)
        case .scale:
            return scaleEffect(popover.readyShow ? 1 : 0.1, anchor: popover.attributes.scaleAnchor).animation(.spring(), value: popover.readyShow)
        case .opacity:
            return opacity(popover.readyShow ? 1.0 : 0).animation(.easeInOut, value: popover.readyShow)
        }
    }
    
    func withTransition(_ popover: Popover) -> any View {
        popover.attributes.transitions.reduce(self, { $0.buildView($1, popover: popover) })
    }
}


extension PopoverContainer {
    @MainActor final class ViewModel: ObservableObject {

        @Published private(set) var popovers: [Popover] = []
        @Published var opacity = 0.3
        
        var bgOpacity: Double {
            popovers.last?.attributes.bgOpacity ?? 0.2
        }
        
        func present(with popover: Popover) {
            popovers.append(popover)
        }
        
        func dismiss(with popover: Popover) {
            guard popover.attributes.tapDismiss else {
                return
            }
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

