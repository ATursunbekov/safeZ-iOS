//
//  SignInView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 17/3/23.
//

import SwiftUI
import AuthenticationServices
struct SignInView: View {
    
    @StateObject  var signInViewModel = SignInViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @State private var email = ""
    @State private var password = ""
    @State private var messageEmail = ""
    @State private var messagePassword = ""
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var hidePassword = true
    @State private var isStatusNavigation = false
    
    var body: some View {
        NavigationView {
            if signInViewModel.isAuthenticated {
                CustomTabView()
            } else {
                ZStack() {
                    Background()
                    orLines
                        .offset(y: 130)
                    signInButton
                    VStack {
                        titleHeader
                        textFields
                        
                        Spacer()
                        
                        appleButton
                        
                        Spacer()
                        
                        signUpButton
                    }
                    .padding(.horizontal, 16)
                }
                .ignoresSafeArea(.keyboard)
                .navigationBarHidden(true)
            }
        }
        .onAppear {
            signInViewModel.checkAuthentication()
        }
    }
    
    var titleHeader: some View {
        HStack() {
            Text("Welcome \nback")
                .foregroundColor(.customBlack)
                .font(.custom(Gilroy.semiBold.rawValue, size: 38))
            
            Spacer()
        }
        .padding(.vertical, 30)
    }
    
    var textFields: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading ,spacing: 4) {
                CustomTextFieldAuth(placeholder: "Email Address", text: $email, isSecure: false, isValidEmail: isEmailValid)
                    .onChange(of: email) { newValue in
                        isEmailValid = true
                        self.messageEmail = ""
                       
                    }
                Text(messageEmail)
                    .font(.custom(Gilroy.regular.rawValue, size: 12))
                    .foregroundColor(.errorRed)
                    .padding(.horizontal, 18)
            }
            VStack(alignment: .trailing, spacing: 4) {
                Group {
                    if hidePassword {
                        CustomTextFieldAuth(placeholder: "Password", text: $password, isSecure: true, isValidPassword: isPasswordValid)
                    } else {
                        CustomTextFieldAuth(placeholder: "Password", text: $password, isSecure: false, isValidPassword: isPasswordValid)
                    }
                }
                .onChange(of: password, perform: { newValue in
                    isPasswordValid = true
                    self.messagePassword = ""
                })
                .overlay(
                    Button(action: {
                        hidePassword.toggle()
                    }, label: {
                        Image(hidePassword ? TextFieldIcon.eye.rawValue : TextFieldIcon.eyeHide.rawValue)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.trailing, isPasswordValid ? 6 : 24)
                    })
                    ,alignment: .trailing
                )
                HStack {
                    Text(messagePassword)
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
                            .offset(y: 5)
                    }
                }
                
            }
        }
    }
    
    var signInButton: some View {
        VStack {
            Button {

                signInViewModel.signIn(email: email, password: password) { result in
                    if result {
                        isStatusNavigation.toggle()
                        isEmailValid = true
                        isPasswordValid = true
                    } else {
                        self.messageEmail = signInViewModel.messageEmail
                        self.messagePassword = signInViewModel.messagePassword
                        isEmailValid = false
                        isPasswordValid = false
                    }
                }
            } label: {
                Text("Sign In")
                    .foregroundColor(.customBlack)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(Color.customPrimary)
                    .cornerRadius(18)
                    .padding(.horizontal, 16)
            }
            .padding(.top, 100)
            NavigationLink(
                destination: CustomTabView()
                    .navigationBarBackButtonHidden(true),
                isActive: $isStatusNavigation,
                label: { EmptyView() }
            )
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
        Button {
        } label: {
            HStack(alignment: .center,spacing: 28) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                Text("Continue with apple")
                    .foregroundColor(.white)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 16))
            }
            .frame(height: 58)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(18)
        }
        .offset(y: 60)
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
        .offset(y: -5)
    }
}

struct Background: View {
    var body: some View {
        GeometryReader { proxy in
            let mult = proxy.safeAreaInsets.bottom == 0 ? 0.9 : 1
            let size = proxy.size.width * 2 * mult
            ZStack() {
                Circle()
                    .fill(
                        Color.backgroundLightPurple
                    )
                    .frame(width: size, height: size)
                    .offset(
                        x: proxy.frame(in: .local).midX - size / 2,
                        y: -proxy.frame(in: .local).midY * 0.8)
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(#colorLiteral(red: 0.9047619104385376, green: 1, blue: 0.7166666984558105, alpha: 1)), location: 0.02083333395421505),
                            .init(color: Color(#colorLiteral(red: 0.8352941274642944, green: 0.9921568632125854, blue: 0.5254902243614197, alpha: 1)), location: 0.6739193201065063),
                            .init(color: Color(#colorLiteral(red: 0.7450980544090271, green: 0.9803921580314636, blue: 0.21960784494876862, alpha: 1)), location: 0.9843153357505798)]),
                        startPoint: UnitPoint(x: -9.423286040366463e-10, y: 0.5255255047858531),
                        endPoint: UnitPoint(x: 0.7439940228917141, y: 0.04054050807289866)))
                    .opacity(0.2)
                    .frame(width: size, height: size)
                    .offset(
                        x: proxy.frame(in: .local).midX - size / 2,
                        y: proxy.frame(in: .local).midY * 1.35)
            }
            .frame(maxHeight: .infinity)
        }
    }
}
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

