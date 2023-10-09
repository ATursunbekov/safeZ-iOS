//
//  SignUpView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 17/3/23.
//

import SwiftUI
import _AuthenticationServices_SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var hidePassword = true
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var showWebView = false
    
    var body: some View {
        VStack {
            titleHeader
            textFields
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(
            VStack(spacing: -140) {
                ShapeCircle(arcHeight: 150, arcPosition: .down)
                    .fill(LinearGradient(
                            gradient: Gradient(stops: [
                        .init(color: Color(#colorLiteral(red: 0.8374999761581421, green: 0.9220008850097656, blue: 1, alpha: 1)), location: 0.02083333395421505),
                        .init(color: Color(#colorLiteral(red: 0.16078431904315948, green: 0.3686274588108063, blue: 0.8078431487083435, alpha: 1)), location: 1)]),
                            startPoint: UnitPoint(x: 0.008746321867005302, y: 0.44444449777440553),
                            endPoint: UnitPoint(x: 0.935860075297171, y: 0.4166666928180862)))
                    .opacity(0.20)
                    .frame(height: 750)
                ShapeCircle(arcHeight: 150, arcPosition: .up)
                    .fill(Color.backgroundLightPurple)
                    .frame(height: 455)
                    .overlay (
                        VStack(spacing: UIScreen.main.bounds.height * 0.035) {
                            VStack(spacing: 18) {
                                text
                                signUpButton
                            }
                            orLines
                            appleButton
                            signInButton
                        }
                        ,alignment: .top
                        )
            }
            .ignoresSafeArea()
        )
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .onDisappear {
            viewModel.messageEmailSignUp = ""
            viewModel.messagePasswordSignUp = ""
        }
    }
    var titleHeader: some View {
        HStack() {
            Text("Create \nAccount")
                .foregroundColor(.customBlack)
                .font(.custom(Gilroy.semiBold.rawValue, size: 38))
            
            Spacer()
        }
        .padding(.top, UIScreen.main.bounds.height * 0.06)
    }
    var textFields: some View {
        VStack(spacing: UIScreen.main.bounds.height * 0.035) {
            VStack(alignment: .leading, spacing: 4) {
                CustomTextFieldAuth(placeholder: "Full name", text: $fullName, isSecure: false, autocapitalizationType: .words)
                Text("")
                    .font(.custom(Gilroy.regular.rawValue, size: 12))
                    .foregroundColor(.errorRed)
                    .padding(.horizontal, 18)
            }
            VStack(alignment: .leading, spacing: 4) {
                CustomTextFieldAuth(placeholder: "Email Address", text: $email, isSecure: false, isValidEmail: isEmailValid, autocapitalizationType: .none)
                    .onChange(of: email) { newValue in
                        isEmailValid = true
                        isPasswordValid = true
                        self.viewModel.messagePasswordSignUp = ""
                        self.viewModel.messageEmailSignUp = ""
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
                Text(viewModel.messageEmailSignUp)
                    .font(.custom(Gilroy.regular.rawValue, size: 12))
                    .foregroundColor(.errorRed)
                    .padding(.horizontal, 18)
            }
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    if hidePassword {
                        CustomTextFieldAuth(placeholder: "Password", text: $password, isSecure: true, isValidPassword: isPasswordValid, autocapitalizationType: .none)
                    } else {
                        CustomTextFieldAuth(placeholder: "Password", text: $password, isSecure: false,  isValidPassword: isPasswordValid, autocapitalizationType: .none)
                    }
                }
                .onChange(of: password, perform: { newValue in
                    isPasswordValid = true
                    isEmailValid = true
                    self.viewModel.messagePasswordSignUp = ""
                    self.viewModel.messageEmailSignUp = ""
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
                Text(viewModel.messagePasswordSignUp)
                    .font(.custom(Gilroy.regular.rawValue, size: 12))
                    .foregroundColor(.errorRed)
                    .padding(.horizontal, 18)
            }
        }
        .padding(.top, UIScreen.main.bounds.height * 0.02)
    }
    
    var text: some View {
        VStack(spacing: 3) {
            Text("By continuing you agree to our")
                .foregroundColor(Color.black)
                .font(.custom(Gilroy.regular.rawValue, size: 14)) +
            Text(" T&Cs and")
                .font(.custom(Gilroy.semiBold.rawValue, size: 14))
                .foregroundColor(.primarySubtle)
            Text("Privacy Policy")
                .font(.custom(Gilroy.semiBold.rawValue, size: 14))
                .foregroundColor(.primarySubtle)
        }.onTapGesture {
            showWebView = true
        }
        .fullScreenCover(isPresented: $showWebView) {
            WebViewWrapper(showWebView: $showWebView, urlString: "https://www.iguard.app/privacypolicy")
        }

    }
    var signUpButton: some View {
        Button {
            createUserAction()
        } label: {
            Text("Sign Up")
                .foregroundColor(.white)
                .font(.custom(Gilroy.medium.rawValue, size: 18))
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.size.height / 15.5)
                .background(Color.customPrimary)
                .cornerRadius(18)
                .padding(.horizontal, 16)
                .shadow(color: .shadowTFLogin, radius: 20, x: 13, y: 16)
        }
    }
    var orLines: some View {
        HStack(spacing: 13) {
            Spacer()
            
                .frame(width: 100, height: 1)
                .background(Color.subtle2)
            Text("OR")
                .font(.custom(Gilroy.regular.rawValue, size: 12))
                .foregroundColor(.subtle2)
            
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
    
    var signInButton: some View {
        HStack {
            Text("Already have an account?")
                .font(.custom(Gilroy.regular.rawValue, size: 16))
            Button("Sign In") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.custom(Gilroy.medium.rawValue, size: 16))
            .foregroundColor(.primarySubtle)
        }
    }
    
    func createUserAction() {
        guard viewModel.inputsAreNotEmpty(fullName, email, password) else {
            return
        }
        FaceIDAuthenticationManager.authenticate { result in
            if result {
                viewModel.createUser(fullName, email, password) { result in
                    switch result {
                    case .success(_):
                        isEmailValid = true
                        isPasswordValid = true
                        
                        UserDefaults.standard.setValue(true, forKey: "isTrialActive")
                        
                        viewModel.signIn(email, password) { _ in}
                        
                        let expirationDate = Date().addingTimeInterval(3 * 24 * 60 * 60)
                        
                        UserDefaults.standard.set(expirationDate, forKey: "trialExpirationDate")
                        
                    case .failure(let failure):
                        switch failure {
                        case .invalidEmail:
                            isEmailValid = false
                        case .emailAlreadyInUse:
                            isEmailValid = false
                        case .weakPassword:
                            isPasswordValid = false
                        default:
                            print(failure.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}
struct SignUpView_Preview: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
