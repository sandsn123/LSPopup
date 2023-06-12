//
//  View+Popup.swift
//  LSPopup
//
//  Created by czi on 2023/6/5.
//

import SwiftUI

public extension View {
    func lspopup(isPresent: Binding<Bool>,
                   bgOpacity: Double = 0,
                   attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = { _ in },
                   @ViewBuilder popover: @escaping () -> some View) -> some View {
        modifier(
            PopoverModifier(isPresented: isPresent, bgOpacity: bgOpacity, attributes: buildAttributes, view: popover)
        )
    }
}

