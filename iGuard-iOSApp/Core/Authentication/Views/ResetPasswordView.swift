//
//  ResetPasswordView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 17/3/23.
//

import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var show = false
    @Environment(\.presentationMode) private var presentationMode
    @State private var email = ""
    @State private var isValidEmail = true
    @State private var hideCancelButton = true
    var body: some View {
        ZStack {
            VStack() {
                header
                emailTextField
                
                Spacer()
                
                resetPasswordButton
                
            }
            .padding(.horizontal, 16)
            VStack(spacing: 4) {
                Spacer()
                DropdownMenuForget(show: $show, messageText: $email, hideCancelButton: $hideCancelButton).offset(y: self.show ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 15 : UIScreen.main.bounds.height)
            }
            .background(Color(UIColor.black.withAlphaComponent(self.show ? 0.5 : 0)).edgesIgnoringSafeArea(.all))
            .ignoresSafeArea(.keyboard)
            .navigationBarHidden(true)
        }.background(
            VStack(spacing: -70) {
                ShapeCircle(arcHeight: 150, arcPosition: .down)
                    .fill(
                        Color.lightPurple
                    )
                    .frame(height: 750)
                Text("")
                ShapeCircle(arcHeight: 150, arcPosition: .up)
                    .fill(LinearGradient(
                                gradient: Gradient(stops: [
                            .init(color: Color(#colorLiteral(red: 0.8374999761581421, green: 0.9220008850097656, blue: 1, alpha: 1)), location: 0.02083333395421505),
                            .init(color: Color(#colorLiteral(red: 0.16078431904315948, green: 0.3686274588108063, blue: 0.8078431487083435, alpha: 1)), location: 1)]),
                                startPoint: UnitPoint(x: 0.008746321867005302, y: 0.44444449777440553),
                                endPoint: UnitPoint(x: 0.935860075297171, y: 0.4166666928180862)))
                    .opacity(0.2)
                    .frame(height: 450)
            }.ignoresSafeArea()
        )
        .onDisappear {
            viewModel.messageEmailReset = ""
        }
    }
    private var cancelButton: some View {
        HStack {
            Spacer()
            if hideCancelButton {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.primarySubtle)
                .font(.custom(Gilroy.medium.rawValue, size: 18))
            } else {
                Text("")
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 22) {
            cancelButton
            VStack(alignment: .leading ,spacing: 24) {
                HStack() {
                    Text("Forgot password")
                        .font(.custom(Gilroy.semiBold.rawValue, size: 38))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                Text("We will send you a link to reset \nyour password to your email")
                    .font(.custom(Gilroy.regular.rawValue, size: 18))
            }
        }
    }
    private var emailTextField: some View {
        VStack(alignment: .leading, spacing: 4) {
            CustomTextFieldAuth(placeholder: "Email", text: $email, isSecure: false, isValidEmail: isValidEmail, autocapitalizationType: .none)
                .onChange(of: email) { newValue in
                    isValidEmail = true
                    viewModel.messageEmailReset = ""
                }
                .overlay(
                    HStack {
                        if !isValidEmail {
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
            Text(viewModel.messageEmailReset)
                .font(.custom(Gilroy.regular.rawValue, size: 12))
                .foregroundColor(.errorRed)
                .padding(.horizontal, 18)
        }       
        .padding(.top, 30)
    }
    private var resetPasswordButton: some View {
        Button {
            viewModel.resetPassword(email) { result in
                switch result {
                case true:
                    show.toggle()
                    hideCancelButton = false
                case false:
                    isValidEmail = false
                    hideCancelButton = true
                }
            }
        } label: {
            Text("Reset password")
                .foregroundColor(.white)
                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.size.height / 15.5)
                .background(Color.customPrimary)
                .cornerRadius(18)
                .shadow(color: .shadowTFLogin, radius: 20, x: 13, y: 16)
                .padding(.bottom)
        }
    }
}
struct ResetPassword_Preview: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
            .environmentObject(AuthViewModel())
    }
}
