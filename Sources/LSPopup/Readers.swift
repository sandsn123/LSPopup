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


struct WindowReader: UIViewRepresentable {
    @Binding var window: UIWindow?

  @MainActor
  final class View: UIView {
    var didMoveToWindowHandler: ((UIWindow?) -> Void)

    init(didMoveToWindowHandler: (@escaping (UIWindow?) -> Void)) {
      self.didMoveToWindowHandler = didMoveToWindowHandler
      super.init(frame: .null)
      backgroundColor = .clear
      isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
      super.didMoveToWindow()
      didMoveToWindowHandler(window)
    }
  }

  func makeUIView(context: Context) -> View {
      .init { window = $0 }
  }

  func updateUIView(_ uiView: View, context: Context) {
      uiView.didMoveToWindowHandler = { window = $0 }
  }
}

extension View {
    @ViewBuilder
  func onWindowChange(_ window: Binding<UIWindow?>) -> some View {
      if #available(iOS 15.0, *) {
        background {
              WindowReader(window: window)
          }
      } else {
        background(
            WindowReader(window: window)
         )
      }
  }
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

