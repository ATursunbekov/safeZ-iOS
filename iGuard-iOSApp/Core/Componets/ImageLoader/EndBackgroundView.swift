//
//  EndBackgroundView.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 4/7/23.
//

import SwiftUI

struct EndBackgroundView: View {
    var body: some View {
        ZStack {
            Color.backgroundCircleSplash
                .ignoresSafeArea()
            VStack(spacing: 0) {
                LinearGradient(gradient: Gradient(colors: [.backgroundCircleSplash, .black.opacity(0.7)]), startPoint: .bottom, endPoint: .top)
                    .frame(height: UIScreen.main.bounds.height * (229 / 896))
                    .ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(SplashImage.logoForSplash.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width * (170 / 414), height: UIScreen.main.bounds.height * (207 / 896) )
                            .offset(y: 40)
                        Text("SafeZ")
                            .foregroundColor(.black)
                            .font(.custom(Gilroy.semiBold.rawValue, size: 57)
                            )
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .blur(radius: 3)
                    .padding(.top, 40)
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EndBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        EndBackgroundView()
    }
}
