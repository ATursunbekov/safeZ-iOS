//
//  DropdownMenuScannedInfo.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 25/7/23.
//

import SwiftUI

struct DropdownMenuScannedInfo: View {
    @EnvironmentObject var viewModel: DocumentsViewModel
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @Binding var showSaveMenu: Bool
    @Environment(\.presentationMode) var presentationMode
    var selectedState: String
    var selectedClass: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 38) {
            VStack(alignment: .leading, spacing: 25) {
                Text("Verify information provided")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 22))
                Text("I \(homeViewModel.currentUserFullName) do certify that I am the person who identity is represented on the saved identification")
                    .font(.custom(Gilroy.regular.rawValue, size: 16))
                    .frame(maxHeight: 50)

            }
            VStack(spacing: 18) {
                Button {
                    FaceIDAuthenticationManager.authenticate { success in
                        if success {
                            viewModel.saveDriverLicense(state: selectedState, drivingClass: selectedClass)
                            isPresented = false
                            homeViewModel.getDriverLicenseInfo()
                            showSaveMenu = false
                        }
                    }
                } label: {
                    Text("Verify")
                        .foregroundColor(.white)
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.size.height / 15.5)
                        .background(Color.customPrimary)
                        .cornerRadius(18)
                        .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                }
                Button {
                        showSaveMenu = false
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
