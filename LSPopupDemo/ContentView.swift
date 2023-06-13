//
//  ContentView.swift
//  LSPopupDemo
//
//  Created by 李赛 on 2023/6/12.
//

import SwiftUI
import LSPopup

struct ContentView: View {
    @State var isPresent = false
    @State var subPresent = false

    var body: some View {
        
        ZStack {
            Rectangle().fill(.red).frame(width: 100, height: 100)
                .onTapGesture {
                    isPresent.toggle()
                }
                .lspopup(isPresent: $isPresent, attributes: {
                    $0.cornerRadius = 10.0
                    $0.anchor = .absolute(originAnchor: .topRight, popoverAnchor: .topLeft)
                    $0.padding = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
                    $0.bgOpacity = 0
                    $0.transitions = [.scale, .opacity]
//                    $0.tapDismiss = false
                }) {
                    Rectangle().fill(.blue).frame(width: 300, height: 300)
                        .onTapGesture {
                            subPresent.toggle()
                        }
                        .lspopup(isPresent: $subPresent, attributes: {
                            $0.cornerRadius = 10.0
                            $0.anchor = .absolute(originAnchor: .bottomRight, popoverAnchor: .topLeft)
                            $0.padding = EdgeInsets(top: -20, leading: -20, bottom: 0, trailing: 0)
                            $0.bgOpacity = 0.3
//                            $0.tapDismiss = true
                        }) {
                            Rectangle().fill(.purple).frame(width: 300, height: 300)
                                .onTapGesture {}
                        }
                }
                .position(x: 200, y: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
