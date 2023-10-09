//
//  DropdownMenuDocument.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 6/7/23.
//

import SwiftUI

struct DropdownMenuDocument: View {
    @EnvironmentObject var documentsViewModel: DocumentsViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Binding var showMenuDelete: Bool
    @State var isRegistrationImage: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 38) {
            VStack(alignment: .leading, spacing: 25) {
                Text("Delete document")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 22))
            }
            VStack(spacing: 18) {
                Button {
                    if isRegistrationImage {
                        documentsViewModel.imageURLRegistration = nil
                        documentsViewModel.deleteImage(folder: .carRegistration)
                        documentsViewModel.deleteFieldImage(folder: .carRegistration)
                    } else {
                        documentsViewModel.imageURLInsurance = nil
                        documentsViewModel.deleteImage(folder: .carInsurance)
                        documentsViewModel.deleteFieldImage(folder: .carInsurance)
                    }
                    homeViewModel.getDocuments()
                    showMenuDelete = false
                } label: {
                    Text("Yes")
                        .foregroundColor(.white)
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.size.height / 15.5)
                        .background(Color.primarySubtle)
                        .cornerRadius(18)
                        .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                }
                Button {
                        showMenuDelete = false
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
        .padding(.horizontal,22)
        .padding(.bottom,(UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30)
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.12), radius: 2, x: -2)
    }
}
