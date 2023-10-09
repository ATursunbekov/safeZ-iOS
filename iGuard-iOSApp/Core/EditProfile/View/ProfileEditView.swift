//
//  EditProfile.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 20/3/23.
//

import SwiftUI
import Introspect
import Kingfisher
import FirebaseAuth

struct ProfileEditView: View {
    @StateObject private var viewModel = ProfileEditViewModel()
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @Binding var tabBarShow: Bool
    @Binding var showMenuDelete: Bool
    @Binding var showMenuEditPicture: Bool
    @State var imageAvatar: UIImage?
    @State var isPasswordTextFieldActive = false
    @State var isConfirmPasswordTextFieldActive = false
    //For Textfields
    @State private var isLoading = false
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var hidePassword = true
    @State private var hideConfirmPassword = true
    
    @Environment (\.presentationMode) private var presentationMode
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init(tabBarShow: Binding<Bool>, showMenuDelete: Binding<Bool>, showMenuEditPicture: Binding<Bool>) {
        _tabBarShow = tabBarShow
        _showMenuDelete = showMenuDelete
        _showMenuEditPicture = showMenuEditPicture
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: Gilroy.semiBold.rawValue, size: 18)!]
    }
    
    
    var body: some View {
        ActivityIndicatorView(isDisplayed: $authViewModel.isLoading) {
            ScrollView(showsIndicators: false) {
                VStack {
                    addAvatar
                    textFieldsAndButton
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .overlay(
            VStack(spacing: 4) {
                Spacer()
                DropdownMenuDeleteUser(show: $showMenuDelete, tabBarShow: $tabBarShow).offset(y: self.showMenuDelete ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30 : UIScreen.main.bounds.height)
            }
                .background(Color(UIColor.black.withAlphaComponent(self.showMenuDelete ? 0.5 : 0)).edgesIgnoringSafeArea(.all))
                .animation(.easeInOut(duration: 0.5))
        )
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(ProfileIcons.arrowBack.rawValue)
                }
                .frame(width: 35, height: 30, alignment: .leading)
                .allowsHitTesting(authViewModel.isHitTestingEnabled)
            }
        }
        .introspectTabBarController { (UITabBarController) in
            if showMenuEditPicture || showMenuDelete {
                UITabBarController.tabBar.isHidden = true
            } else {
                UITabBarController.tabBar.isHidden = false
            }
        }
        .overlay(
            VStack(spacing: 4) {
                Spacer()
                DropdownMenuEditProfilePicture(showMenuEditPicture: $showMenuEditPicture, showTabBar: $tabBarShow, showingImagePicker: $showingImagePicker, showingCamera: $showingCamera) {
                    imageAvatar = nil
                    homeViewModel.getDriverLicenseInfo()
                }
                .offset(y: self.showMenuEditPicture ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30: UIScreen.main.bounds.height)
            }
                .background(Color(UIColor.black.withAlphaComponent(self.showMenuEditPicture ? 0.5 : 0)).edgesIgnoringSafeArea(.all))
                .animation(.easeInOut(duration: 0.5))
        )
        .allowsHitTesting(authViewModel.isHitTestingEnabled)
    }
    var addAvatar: some View {
        VStack(spacing: 14) {
            if let imageAvatar = imageAvatar {
                Image(uiImage: imageAvatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(50)
                    .clipped()
                Text("Edit picture")
            } else {
                if let avatarUser = viewModel.avatarUser {
                    KFImage(avatarUser)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(50)
                    Text("Edit picture")
                } else {
                    Image(ProfileIcons.addAvatar.rawValue)
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(Color.backgroundCircleSplash)
                        .frame(width: 100, height: 100)
                        .cornerRadius(50)
                    Text("Add picture")
                }
            }
        }
        .overlay(
            Group {
                if isLoading {
                    ActivityIndicator(style: .large)
                }
            }
        )
        .onTapGesture {
            showMenuEditPicture.toggle()
            tabBarShow.toggle()
        }
        .foregroundColor(.customPrimary)
        .font(.custom(Gilroy.semiBold.rawValue, size: 14))
        .padding(.top, 40)
        .padding(.bottom, 36)
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $imageAvatar, imageType: .avatar, isForProfileView: false)
                .onDisappear {
                    tabBarShow = true
                }
                .onAppear {
                    showMenuEditPicture.toggle()
                }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(image: $imageAvatar, imageType: .avatar, sourceType: .camera, isForProfileView: false)
                .ignoresSafeArea()
                .onDisappear {
                    tabBarShow = true
                }
                .onAppear {
                    showMenuEditPicture.toggle()
                }
        }
    }
    var textFieldsAndButton: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                CustomTextFieldProfile(placeholder: "Full Name", text: $viewModel.fullName, isSecure: false, isEditable: true, autocapitalizationType: .words)
                Text("")
            }
            VStack(alignment: .leading ,spacing: 4) {
                CustomTextFieldProfile(placeholder: "Email Address", text: $viewModel.email, isSecure: false, isEditable: false, autocapitalizationType: .none)
                Text("")
            }
            if !viewModel.isAppleIDUser {
                VStack(alignment: .leading ,spacing: 4) {
                    Group {
                        if hidePassword {
                            CustomTextFieldProfile(placeholder: "Password", text: $password, isSecure: true, isValidPassword: viewModel.isPasswordValid, isEditable: true, autocapitalizationType: .none)
                        } else {
                            CustomTextFieldProfile(placeholder: "Password", text: $password, isSecure: false, isValidPassword: viewModel.isPasswordValid, isEditable: true, autocapitalizationType: .none)
                        }
                    }
                    .overlay(
                        HStack {
                            Button {
                                hidePassword.toggle()
                            } label: {
                                Image(hidePassword ? TextFieldIcon.eye.rawValue : TextFieldIcon.eyeHide.rawValue)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            if !viewModel.isPasswordValid {
                                Button {
                                    password = ""
                                } label: {
                                    Image(HomeImage.iconoirCancel.rawValue)
                                }
                            }
                        }
                            .padding(.trailing, 18)
                        , alignment: .trailing
                    )
                    Text(viewModel.messagePassword)
                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                        .foregroundColor(.errorRed)
                        .padding(0)
                        .padding(.horizontal, 18)
                }
                .onChange(of: password, perform: { newValue in
                    viewModel.isPasswordValid = true
                    self.viewModel.messagePassword = ""
                    self.viewModel.messageConfirmPassword = ""
                    self.isPasswordTextFieldActive = password.isEmpty ? false : true
                    print(isPasswordTextFieldActive)
                })
                VStack(alignment: .leading ,spacing: 4) {
                    Group {
                        if hideConfirmPassword {
                            CustomTextFieldProfile(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, isValidPassword: viewModel.isPasswordValid, isEditable: true, autocapitalizationType: .none)
                        } else {
                            CustomTextFieldProfile(placeholder: "Confirm Password", text: $confirmPassword, isSecure: false,  isValidPassword: viewModel.isPasswordValid, isEditable: true, autocapitalizationType: .none)
                        }
                    }
                    .overlay(
                        HStack {
                            Button {
                                hideConfirmPassword.toggle()
                            } label: {
                                Image(hideConfirmPassword ? TextFieldIcon.eye.rawValue : TextFieldIcon.eyeHide.rawValue)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            if !viewModel.isPasswordValid {
                                Button {
                                    confirmPassword = ""
                                } label: {
                                    Image(HomeImage.iconoirCancel.rawValue)
                                }
                            }
                        }
                            .padding(.trailing, 18)
                        , alignment: .trailing
                    )
                    Text(viewModel.messagePassword)
                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                        .foregroundColor(.errorRed)
                        .padding(.horizontal, 18)
                }
                .onChange(of: confirmPassword, perform: { newValue in
                    viewModel.isPasswordValid = true
                    viewModel.isPasswordValid = true
                    self.viewModel.messagePassword = ""
                    self.viewModel.messageConfirmPassword = ""
                    self.isConfirmPasswordTextFieldActive = confirmPassword.isEmpty ? false : true
                })
            }
            VStack(spacing: 48) {
                actionButton
                Button {
                    showMenuDelete.toggle()
                    tabBarShow.toggle()
                } label: {
                    HStack(spacing: 12) {
                        Image(ProfileIcons.delete.rawValue)
                        Text("Delete Account")
                            .font(.custom(Gilroy.regular.rawValue, size: 12))
                            .foregroundColor(.errorRed)
                        Spacer()
                    }
                    .offset(y: -7)
                }
            }
        }
    }
        var actionButton: some View {
            Button {
                if !isPasswordTextFieldActive && !isConfirmPasswordTextFieldActive {
                    isLoading = true
                    var hasUploadedImage = false
                    viewModel.uploadImageStorage(path: .avatar, image: imageAvatar) { result in
                        if result {
                            hasUploadedImage = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isLoading = true
                                if hasUploadedImage {
                                    homeViewModel.getDriverLicenseInfo()
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                        viewModel.updateFullName { result in
                            if result && !hasUploadedImage {
                                homeViewModel.getDriverLicenseInfo()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                } else {
                    viewModel.changePassword(newPassword: password, confirmPassword: confirmPassword) { result in
                        if result {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            } label: {
                Text("Save")
                    .foregroundColor(.white)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.size.height / 15.5)
                    .background(Color.customPrimary)
                    .cornerRadius(18)
            }
        }
    }
