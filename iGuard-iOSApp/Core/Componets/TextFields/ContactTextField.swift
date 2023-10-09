//
//  ContactTextField.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 16/4/23.
//

import SwiftUI

struct ContactTextField: View {
    let placeholder: String
    @Binding var text: String
    let isEditable: Bool
    var showError: Bool
    let autocapitalizationType: UITextAutocapitalizationType
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 0) {
                if text != "" && placeholder != "Name" {
                    Text(placeholder)
                        .foregroundColor(.blackAlpha60)
                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                    Spacer()
                        .frame(height: 4)
                }
                TextField(placeholder, text: $text)
                    .disabled(!isEditable)
            }
            .padding(.vertical, 8)
        }
        .placeholder(when: text.isEmpty) {
            Text(placeholder)
                .foregroundColor(.blackAlpha60)
        }
        .autocapitalization(autocapitalizationType)
        .autocorrectionDisabled(true)
        .foregroundColor(.black)
        .frame(height: 54)
        .padding(.horizontal, 18)
        .background(Color.white)
        .font(.custom(Gilroy.regular.rawValue, size: 16))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(lineWidth: 1)
                .foregroundColor(showError && text.isEmpty ? Color.red : Color.primarySubtle)
        )
    }
}

