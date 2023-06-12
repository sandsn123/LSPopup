//
//  File.swift
//  
//
//  Created by sai on 2023/6/12.
//

import SwiftUI

struct StateObjectView<ViewModel: ObservableObject, Content: View>: View {
    let viewModel: ViewModel
    let content: () -> Content
    
    init(viewModel: ViewModel, @ViewBuilder content: @escaping () -> Content) {
        self.viewModel = viewModel
        self.content = content
    }
    
    var body: some View {
        if #available(iOS 14, *) {
            StateObjectView14(viewModel: viewModel, content: content)
        } else {
            StateObjectView13(viewModel: viewModel, content: content)
        }
    }
}

@available(iOS 14.0, *)
private struct StateObjectView14<ViewModel: ObservableObject, Content: View>: View {
    @StateObject var viewModel : ViewModel
    let content: () -> Content
    
    init(viewModel: ViewModel, content: @escaping () -> Content) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.content = content
    }
    
    var body: some View {
        content()
            .environmentObject(viewModel)
    }
}

private struct StateObjectView13<ViewModel: ObservableObject, Content: View>: View {
    @ObservedObject var viewModel : ViewModel
    let content: () -> Content

    var body: some View {
        content()
            .environmentObject(viewModel)

    }
}

struct ChangeObserver<Content: View, Value: Equatable>: View {
    let content: Content
    let value: Value
    let action: (Value) -> Void

    init(value: Value, action: @escaping (Value) -> Void, content: @escaping () -> Content) {
        self.value = value
        self.action = action
        self.content = content()
        _oldValue = State(initialValue: value)
    }

    @State private var oldValue: Value

    var body: some View {
        DispatchQueue.main.async {
            if oldValue != value {
                action(value)
                oldValue = value
            }
        }
        return content
    }
}

public extension View {
    /// Detect changes in bindings (fallback of `.onChange` for iOS 13+).
    func onValueChange<Value: Equatable>(
        of value: Value,
        _ action: @escaping (_ newValue: Value) -> Void
    ) -> some View {
        if #available(iOS 14.0, *) {
            return onChange(of: value, perform: action)
        } else {
            
            return ChangeObserver(value: value, action: action) {
                self
            }
        }
    }
}
