//
//  DeleteContact.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 16/4/23.
//

import SwiftUI

struct DropdownMenuDelete: View {
    @EnvironmentObject private var viewModel: ContactsViewModel
    @Binding var showMenuDelete: Bool
    @Binding var showTabBar: Bool
    @State private var offset = CGSize.zero
    @Environment(\.presentationMode) var presentationMode
    let contactModel: ContactModel
    
    var body: some View {
        VStack(spacing: 25) {
            VStack(alignment: .leading, spacing: 25) {
                Text("Delete contact")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 22))
                Text("Are you sure to delete this contact?")
                    .font(.custom(Gilroy.regular.rawValue, size: 16))
            }
            VStack(spacing: 18) {
                Button {
                    showMenuDelete = false
                    showTabBar = true
                    withAnimation(.spring()) {
                        viewModel.deleteContact(email: contactModel.email)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    Text("Yes")
                        .foregroundColor(.white)
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.size.height / 15.5)
                        .background(Color.customPrimary)
                        .cornerRadius(18)
                        .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                }
                Button {
                    showMenuDelete = false
                    showTabBar = true
                    withAnimation(.spring()){
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Cancel")
                        .foregroundColor(.black)
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.size.height / 15.5)
                        .overlay(RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(lineWidth: 1.09)
                            .foregroundColor(.primarySubtle))
                        .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                }
            }
        }
        .padding(.top, 30)
        .padding(.horizontal,16)
        .padding(.bottom,(UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30)
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
}
