//
//  Readers.swift
//  LSPopup
//
//  Created by czi on 2023/6/5.
//

import SwiftUI

extension EnvironmentValues {
    /// Designates the `UIWindow` hosting the views within the current environment.
    var window: UIWindow? {
        get {
            self[WindowEnvironmentKey.self]
        }
        set {
            self[WindowEnvironmentKey.self] = newValue
        }
    }

    private struct WindowEnvironmentKey: EnvironmentKey {
        typealias Value = UIWindow?

        static var defaultValue: UIWindow? = nil
    }
}


public struct WindowReader<Content: View>: View {

    /// Your SwiftUI view.
    public let view: (UIWindow?) -> Content

    /// The read window.
    @EnvironmentObject var windowViewModel: WindowViewModel
    
    /// Reads the `UIWindow` that hosts some SwiftUI content.
    public init(@ViewBuilder view: @escaping (UIWindow?) -> Content) {
        self.view = view
    }

    public var body: some View {
        view(windowViewModel.window)
            .background(
                WindowHandlerRepresentable().environmentObject(windowViewModel)
            )
    }

    /// A wrapper view to read the parent window.
    private struct WindowHandlerRepresentable: UIViewRepresentable {
        @EnvironmentObject var windowViewModel: WindowViewModel

        func makeUIView(context _: Context) -> WindowHandler {
            return WindowHandler(windowViewModel: self.windowViewModel)
        }

        func updateUIView(_: WindowHandler, context _: Context) {}
    }

    private class WindowHandler: UIView {
        var windowViewModel: WindowViewModel

        init(windowViewModel: WindowViewModel) {
            self.windowViewModel = windowViewModel
            super.init(frame: .zero)
            backgroundColor = .clear
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("[Popovers] - Create this view programmatically.")
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()

            DispatchQueue.main.async {
                /// Set the window.
                self.windowViewModel.window = self.window
            }
        }
    }
}

class WindowViewModel: ObservableObject {
    @Published var window: UIWindow?
}

// -----------  frame size --------------

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue = CGRect.zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private struct ContentSizeReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize { return CGSize() }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

public extension View {
    /// Reads the view frame and bind it to the reader.
    /// - Parameters:
    ///   - coordinateSpace: a coordinate space for the geometry reader.
    ///   - reader: a reader of the view frame.
    func frameReader(in coordinateSpace: CoordinateSpace = .global,
                   for reader: Binding<CGRect>) -> some View {
        frameReader(in: coordinateSpace) { value in
            reader.wrappedValue = value
        }
    }
    
    /// Reads the view frame and send it to the reader.
    /// - Parameters:
    ///   - coordinateSpace: a coordinate space for the geometry reader.
    ///   - reader: a reader of the view frame.
    func frameReader(in coordinateSpace: CoordinateSpace = .global,
                   for reader: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(
                        key: FramePreferenceKey.self,
                        value: geometryProxy.frame(in: coordinateSpace)
                    )
                    .onPreferenceChange(FramePreferenceKey.self, perform: reader)
            }
            .hidden()
        )
    }
    
    func sizeReader(in coordinateSpace: CoordinateSpace = .global,
                   for reader: Binding<CGSize>) -> some View {
        sizeReader { value in
            reader.wrappedValue = value
        }
    }
    
    func sizeReader(transaction: Transaction? = nil, size: @escaping (CGSize) -> Void) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ContentSizeReaderPreferenceKey.self, value: geometry.size)
                    .onPreferenceChange(ContentSizeReaderPreferenceKey.self) { newValue in
                        DispatchQueue.main.async {
                            size(newValue)
                        }
                    }
            }
            .hidden()
        )
    }
}

