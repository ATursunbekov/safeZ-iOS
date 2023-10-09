//  SignInView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 17/3/23.
//

import SwiftUI
import AuthenticationServices
import AVFoundation
struct SignInView: View {
    
    @EnvironmentObject private var viewModel: AuthViewModel
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var email = ""
    @State private var password = ""
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var hidePassword = true
    @State private var disableButton = false
    @State private var cameraAuthorized = false
    @State private var microphoneAuthorized = false
    
    var body: some View {
        if viewModel.userSession == nil {
            VStack {
                titleHeader
                textFields
                
                
                Spacer()
                
                signUpButton
            }
            .padding(.horizontal, 16)
            .background(
                VStack(spacing: -70) {
                    ShapeCircle(arcHeight: 150, arcPosition: .down)
                        .fill(
                            Color.backgroundLightPurple
                        )
                        .frame(height: 750)
                        .overlay(
                            signInButton
                                .padding(.bottom, 125)
                                .padding(.horizontal, 16)
                            ,alignment: .bottom
                        )
                    orLines
                    
                    ShapeCircle(arcHeight: 150, arcPosition: .up)
                        .fill(LinearGradient(
                                gradient: Gradient(stops: [
                            .init(color: Color(#colorLiteral(red: 0.8374999761581421, green: 0.9220008850097656, blue: 1, alpha: 1)), location: 0.02083333395421505),
                            .init(color: Color(#colorLiteral(red: 0.16078431904315948, green: 0.3686274588108063, blue: 0.8078431487083435, alpha: 1)), location: 1)]),
                                startPoint: UnitPoint(x: 0.008746321867005302, y: 0.44444449777440553),
                                endPoint: UnitPoint(x: 0.935860075297171, y: 0.4166666928180862)))
                        .opacity(0.2)
                        .frame(height: 450)
                        .overlay (
                            appleButton
                                .padding(.top, 125)
                            ,alignment: .top
                        )
                }.ignoresSafeArea()
            )
            .ignoresSafeArea(.keyboard)
            .navigationBarHidden(true)
            .onDisappear {
                viewModel.messageEmailSignIn = ""
                viewModel.messagePasswordSignIn = ""
                isEmailValid = true
                isPasswordValid = true
                email = ""
                password = ""
            }
        } else {
            CustomTabView()
                .onAppear {
                    homeViewModel.getDriverLicenseInfo()
                    homeViewModel.getDocuments()
                }
        }
    }
    var titleHeader: some View {
        HStack() {
            Text("Welcome \nback")
                .foregroundColor(.customBlack)
                .font(.custom(Gilroy.semiBold.rawValue, size: 38))
            
            Spacer()
            
        }
        .padding(.top, UIScreen.main.bounds.height * 0.06)
    }
    
    var textFields: some View {
        VStack(spacing: 36) {
            VStack(alignment: .leading ,spacing: 4) {
                CustomTextFieldAuth(placeholder: "Email Address", text: $email, isSecure: false, isValidEmail: isEmailValid, autocapitalizationType: .none)
                    .onChange(of: email) { newValue in
                        isEmailValid = true
                        isPasswordValid = true
                        self.viewModel.messageEmailSignIn = ""
                        self.viewModel.messagePasswordSignIn = ""
                    }
                    .overlay(
                        HStack {
                            if !isEmailValid {
                                Button {
                                    email = ""
                                } label: {
                                    Image(HomeImage.iconoirCancel.rawValue)
                                }
                            }
                        }
                            .padding(.trailing, 18)
                        , alignment: .trailing
                    )
                Text(viewModel.messageEmailSignIn)
                    .font(.custom(Gilroy.regular.rawValue, size: 12))
                    .foregroundColor(.errorRed)
                    .padding(.horizontal, 18)
            }
            VStack(alignment: .trailing, spacing: 7) {
                Group {
                    if hidePassword {
                        CustomTextFieldAuth(placeholder: "Password", text: $password, isSecure: true, isValidPassword: isPasswordValid, autocapitalizationType: .none)
                    } else {
                        CustomTextFieldAuth(placeholder: "Password", text: $password, isSecure: false, isValidPassword: isPasswordValid, autocapitalizationType: .none)
                    }
                }
                .onChange(of: password, perform: { newValue in
                    isEmailValid = true
                    isPasswordValid = true
                    self.viewModel.messagePasswordSignIn = ""
                    self.viewModel.messageEmailSignIn = ""
                })
                .overlay(
                    HStack {
                        Button {
                            hidePassword.toggle()
                        } label: {
                            Image(hidePassword ? TextFieldIcon.eye.rawValue : TextFieldIcon.eyeHide.rawValue)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        if !isPasswordValid {
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
                HStack {
                    Text(viewModel.messagePasswordSignIn)
                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                        .foregroundColor(.errorRed)
                        .padding(.horizontal, 18)
                    Spacer()
                    NavigationLink {
                        ResetPasswordView()
                    } label: {
                        Text("Forgot Password?")
                            .foregroundColor(.primarySubtle)
                            .font(.custom(Gilroy.medium.rawValue, size: 14))
                    }
                }
                
            }
        }
        .padding(.top, UIScreen.main.bounds.height * 0.05)
    }
    
    var signInButton: some View {
        VStack {
            Button {
                guard viewModel.inputsAreNotEmpty(email, password) else {
                    return
                }
                FaceIDAuthenticationManager.authenticate { result in
                    if result {
                        viewModel.signIn(email, password) { result in
                            if result {
                                isEmailValid = true
                                isPasswordValid = true
                            } else {
                                isEmailValid = false
                                isPasswordValid = false
                            }
                        }
                    }
                }
                homeViewModel.getDriverLicenseInfo()
                homeViewModel.getDocuments()
            } label: {
                Text("Sign In")
                    .foregroundColor(.white)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.size.height / 15.5)
                    .background(Color.customPrimary)
                    .cornerRadius(18)
                    .shadow(color: .shadowTFLogin, radius: 20, x: 13, y: 16)
            }
            .disabled(disableButton)
        }
    }
    
    var orLines: some View {
        HStack(spacing: 13) {
            Spacer()
            
                .frame(width: 100, height: 1)
                .background(Color.subtle2)
            Text("OR")
                .font(.custom(Gilroy.regular.rawValue, size: 12))
                .foregroundColor(.forOrColor)
            
            Spacer()
            
                .frame(width: 100, height: 1)
                .background(Color.subtle2)
        }
    }
    var appleButton: some View {
        SignInWithAppleButton(.continue) { request in
            viewModel.handleSignInWithAppleRequest(request)
        } onCompletion: { result in
            viewModel.handleSignInWithAppleCompletion(result)
        }
        .frame(height: UIScreen.main.bounds.size.height / 15.5)
        .cornerRadius(18)
        .padding(.horizontal, 16)
    }
    var signUpButton: some View {
        HStack {
            Text("Don’t have an account?")
                .font(.custom(Gilroy.regular.rawValue, size: 16))
            
            NavigationLink(destination: SignUpView()) {
                Text("Sign Up")
            }
            .font(.custom(Gilroy.medium.rawValue, size: 16))
            .foregroundColor(.primarySubtle)
        }
        .padding(.bottom, UIScreen.main.bounds.height * 0.045)
    }
}

struct SigninView1_Preview: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthViewModel())
    }
}
