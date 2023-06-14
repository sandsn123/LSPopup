//
//  View+Popup.swift
//  LSPopup
//
//  Created by czi on 2023/6/5.
//

import SwiftUI

public extension View {
    func lspopup(isPresent: Binding<Bool>,
                 dismissAction: (() -> Void)? = nil,
                   attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
                   @ViewBuilder popover: @escaping () -> some View) -> some View {
        modifier(
            PopoverModifier(isPresented: isPresent, dismissAction: dismissAction, attributes: buildAttributes, view: popover)
        )
    }
}

