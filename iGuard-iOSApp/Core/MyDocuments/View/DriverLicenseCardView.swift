//
//  DriverLicenseCardView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 11/7/23.
//

import SwiftUI

struct DriverLicenseCardView: View {
    @State private var showUnlock = false
    @Binding var isPresented : Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Driver License/ID")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16.5)
                    .fill(Color.backgroundCircleSplash)
                    .frame(height: 215)
                    .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                VStack(alignment: .leading ,spacing: 23) {
                    HStack(spacing: 18) {
                        Image(DocumentsImage.documentIcon.rawValue)
                            .resizable()
                            .frame(width: 56, height: 56)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Scan Driver license or ID")
                                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                            Text("Swipe to start scanning driver license or ID")
                                .font(.custom(Gilroy.regular.rawValue, size: 12))
                                .foregroundColor(.secondaryText)
                        }
                    }
                    //if showUnlock {
                        SwipeToUnlockDocumentsView(text: "Scan", image: DocumentsImage.scan.rawValue)
                            .onSwipeSuccess {
                                self.isPresented = true
                                self.showUnlock = false
                            }
                            .transition(AnyTransition.scale.animation(Animation.spring(response: 0.3, dampingFraction: 0.5)))
                    }
                //}
                .padding(.leading, 16)
            }
        }
        .padding(.top, 35)
        .onAppear {
            self.showUnlock = true
        }
    }
}
