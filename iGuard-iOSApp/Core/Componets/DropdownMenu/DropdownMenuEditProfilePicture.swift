//
//  DropdownMenuEditProfilePicture.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 10/7/23.
//

import SwiftUI
import Introspect

struct DropdownMenuEditProfilePicture: View {
    @StateObject private var viewModel = ProfileEditViewModel()
    @Binding var showMenuEditPicture: Bool
    @Binding var showTabBar: Bool
    @Binding  var showingImagePicker: Bool
    @Binding  var showingCamera: Bool
    var onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 25) {
            HStack {
                VStack(alignment: .leading, spacing: 42.5) {
                    Text("Edit profile picture")
                        .font(.custom(Gilroy.semiBold.rawValue, size: 22))
                    VStack(alignment: .leading, spacing: 27) {
                        HStack(spacing: 12) {
                            Image(ProfileIcons.camera.rawValue)
                            Text("Take Photo")
                                .font(.custom(Gilroy.medium.rawValue, size: 16))
                            Spacer()
                            Image(ProfileIcons.arrowRight.rawValue)
                        }
                        .onTapGesture {
                            showingCamera.toggle()
                        }
                    HStack(spacing: 12) {
                        Image(ProfileIcons.imageEdit.rawValue)
                        Text("Choose Photo")
                            .font(.custom(Gilroy.medium.rawValue, size: 16))
                        Spacer()
                        Image(ProfileIcons.arrowRight.rawValue)
                    }
                    .onTapGesture {
                        showingImagePicker.toggle()
                    }
                    HStack(alignment: .center ,spacing: 12) {
                        Image(ProfileIcons.delete.rawValue)
                            .frame(width: 24, height: 24)
                        Text("Delete Photo")
                            .font(.custom(Gilroy.medium.rawValue, size: 16))
                        Spacer()
                        Image(ProfileIcons.arrowRight.rawValue)
                    }
                    .onTapGesture {
                        viewModel.deleteImageStorage()
                        showMenuEditPicture.toggle()
                        showTabBar.toggle()
                        onDelete()
                        viewModel.getAvatarUser()
                    }
                    }
                }
                Spacer()
            }
            Button {
                withAnimation(.spring()) {
                    showMenuEditPicture.toggle()
                    showTabBar.toggle()
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
        .padding(.top, 30)
        .padding(.horizontal, 16)
        .padding(.bottom,(UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30)
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
    }
}
