//
//  CustomTextFieldProfile.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 10/4/23.
//

import SwiftUI

struct CustomTextFieldProfile: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    var isValidEmail = true
    var isValidPassword = true
    let isEditable: Bool
    let autocapitalizationType: UITextAutocapitalizationType
    
    var body: some View {
        VStack(alignment: .leading) {
            if isSecure {
                if !isValidPassword {
                    errorText()
                }
                SecureField("", text: $text)
            } else {
                TextField("", text: $text)
                    .disabled(!isEditable)
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
        .overlay(RoundedRectangle(cornerRadius: 18)
        .stroke(isValidPassword  ? Color.primarySubtle : .errorRed, lineWidth: 1))
    }
    private func errorText() -> some View {
        Text(placeholder)
            .foregroundColor(.errorRed)
            .font(.custom(Gilroy.regular.rawValue, size: 12))
    }
}
