//
//  EmptyView.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 20/6/23.
//

import SwiftUI

struct EmptyScreenView: View {
    var image: String
    var titleText: String
    var secText: String
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.customPrimary.opacity(0.30), lineWidth: 1.2)
                    .frame(width: 56, height: 56)
                    .foregroundColor(Color.backgroundLightGreen)
                Image(image)
                    .resizable()
                    .foregroundColor(.customPrimary)
                    .frame(width: width, height: height)
            }
            .padding(.bottom, 18)
            if titleText != "" {
                Text(titleText)
                    .font(.custom(
                        Gilroy.semiBold.rawValue,
                        fixedSize: 16))
                    .foregroundColor(Color.black)
                
            }
            Text(secText)
                .font(.custom(
                    Gilroy.regular.rawValue,
                    fixedSize: 14))
                .foregroundColor(Color.secondaryText)
        }
    }
}

struct EmptyScreenView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyScreenView(image: ContactImage.emptyContacts.rawValue, titleText: "No notifications", secText: "You haven’t added any contact yet", width: 20, height: 23)
    }
}
