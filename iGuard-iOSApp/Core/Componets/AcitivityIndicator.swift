//
//  AcitivityIndicator.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 4/5/23.
//


import SwiftUI

struct ActivityIndicator : UIViewRepresentable {
  
    typealias UIViewType = UIActivityIndicatorView
    let style : UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> ActivityIndicator.UIViewType {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: ActivityIndicator.UIViewType, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
  
}


struct ActivityIndicatorView<Content> : View where Content : View {
    
    @Binding var isDisplayed : Bool
    var content: () -> Content
    
    var body : some View {
            ZStack(alignment: .center) {
                if (!self.isDisplayed) {
                    self.content()
                } else {
                    self.content()
                        .disabled(true)
                        .blur(radius: 3)
                    
                    VStack {
                        ActivityIndicator(style: .large)
                    }
                    .frame(width: 80, height: 80 )
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                }
            }
    }
    
    
}
