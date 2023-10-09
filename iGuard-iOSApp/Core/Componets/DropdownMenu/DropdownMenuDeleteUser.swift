//
//  DropdownMenuEdit.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 12/4/23.
//

import SwiftUI
import Firebase
struct DropdownMenuDeleteUser: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var viewModel: AuthViewModel
    @Binding var show: Bool
    @Binding var tabBarShow: Bool
    @State var text = "Are you sure you want to delete your account?"
    @State var description = "Account deletion is permanent. Proceed?"
    @State var textForButton = "OK"
    
    var body: some View {
        VStack(alignment: .leading ,spacing: 25) {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom(Gilroy.semiBold.rawValue, size: 22))
            Text(description)
                .font(.custom(Gilroy.regular.rawValue, size: 16))
            VStack(spacing: 18) {
                Button {
                    tabBarShow = false
                    show = true
                    if let currentUser = Auth.auth().currentUser,
                       currentUser.providerData.contains(where: { $0.providerID == "password" }) {
                        viewModel.deleteUser { result in
                            if result {
                                viewModel.userSession = nil
                            } else {
                                self.text = "Reauthentication needed"
                                self.description = "This operation is sensitive and requires recent authentication. Log in again before retrying this request."
                            }
                        }
                    }
                    if let currentUser = Auth.auth().currentUser,
                       currentUser.providerData.contains(where: { $0.providerID == "apple.com" }) {
                        Task {
                            await viewModel.deleteAccount()
                        }
                        show = false
                        tabBarShow = true
                    }
                    if text == "Reauthentication needed" {
                        show = false
                        tabBarShow = true
                        presentationMode.wrappedValue.dismiss()
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
                    show = false
                    tabBarShow = true
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
