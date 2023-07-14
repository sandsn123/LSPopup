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
    
    @State var isMuneing = false

    var body: some View {
        let attributes = Popover.Attributes(anchor: .absolute(originAnchor: .bottomRight, popoverAnchor: .topLeft), padding: EdgeInsets(top: -20, leading: -20, bottom: 0, trailing: 0)) {
            isMuneing
        }
       return ZStack {
            Rectangle().fill(.blue).frame(width: 300, height: 300)
                .onTapGesture {
                    subPresent.toggle()
                }
                .lspopup(isPresent: $subPresent, attributes: attributes) {
                    Menu {
                        VStack {
                            Text("1111")
                            Text("2222")
                            Text("33333")
                        }
                        .onAppear {
                            isMuneing = true
                        }
                        .onDisappear {
                            isMuneing = false
                        }
                    } label: {
                        Rectangle().frame(width: 100, height: 100)
                    }

                }
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
