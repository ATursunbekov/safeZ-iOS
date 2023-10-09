//
//  CustomTextField.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 20/3/23.
//

import SwiftUI

struct CustomTextFieldAuth: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    var isValidEmail = true
    var isValidPassword = true
    let autocapitalizationType: UITextAutocapitalizationType
    
    var body: some View {
        VStack(alignment: .leading) {
            if isSecure {
                if !isValidPassword {
                    errorText()
                }
                SecureField("", text: $text)
            } else {
                if !isValidEmail {
                    errorText()
                }
                TextField("", text: $text)
            }
        }
        .placeholder(when: text.isEmpty) {
            Text(placeholder)
                .foregroundColor(.blackAlpha60)
        }
        .autocapitalization(autocapitalizationType)
        .autocorrectionDisabled(true)
        .foregroundColor(.blackAlpha60)
        .frame(height: 54)
        .padding(.horizontal, 18)
        .padding(.trailing, 18)
        .background(Color.white)
        .font(.custom(Gilroy.regular.rawValue, size: 16))
        .cornerRadius(18)
        .shadow(color: .shadowTFLogin, radius: 16, x: 13, y: 16)
        .overlay(RoundedRectangle(cornerRadius: 18)
            .strokeBorder(isValidEmail && isValidPassword ? Color.clear : Color.errorRed, lineWidth: 1)
        )
    }
    
    private func errorText() -> some View {
        Text(placeholder)
            .foregroundColor(.errorRed)
            .font(.custom(Gilroy.regular.rawValue, size: 12))
    }
}
