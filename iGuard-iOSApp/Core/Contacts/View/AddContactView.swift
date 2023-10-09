//
//  AddContactView.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 16/4/23.
//

import SwiftUI
import Contacts

struct AddContactView: View {
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var viewModel: ContactsViewModel
    @Environment(\.presentationMode) private var presentationMode
    @Binding private var showTabBar: Bool
    @Binding private var showMenuContactOptions: Bool
    @State private var showMenuExist = false
    @State private var showMenuMissing = false
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var checkRemoveText = ""
    @State private var showFullNameEmptyError = false
    @State private var showPhoneNumberEmptyError = false
    @State private var showEmailEmptyError = false
    @State private var showFieldsEmptyError = false
    @State private var titleMessage = ""
    @State private var descriptionMessage = ""
    @State private var contact: CNContact?
    @State private var pastedNumber = false
    init(showTabBar: Binding<Bool>, showContactMenu: Binding<Bool>) {
        _showTabBar = showTabBar
        _showMenuContactOptions = showContactMenu
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: Gilroy.semiBold.rawValue, size: 18)!]
    }
    
    var body: some View {
        VStack(spacing: 30) {
            header
                .padding(.bottom, 30)
            VStack {
                ContactTextField(placeholder: "Full Name", text: $fullName, isEditable: true, showError: showFullNameEmptyError, autocapitalizationType: .words)
                if showFullNameEmptyError {
                    Text("Full name field is empty")
                        .foregroundColor(.red)
                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 19)
                }
            }
            VStack {
                TextFieldNumber(placeholder: "Phone number", number: $phoneNumber, pastedNumber: $pastedNumber, showError: showPhoneNumberEmptyError)
                if showPhoneNumberEmptyError {
                    Text("Phone number field is empty")
                        .foregroundColor(.red)
                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 19)
                }
            }

            VStack(alignment: .leading) {
                ContactTextField(placeholder: "Email", text: $email, isEditable: true, showError: showEmailEmptyError, autocapitalizationType: .none)
                if showEmailEmptyError {
                    Text("Email field is empty")
                        .foregroundColor(.red)
                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 19)
                }
                ContactPickerButton(contact: $contact) {
                        Label("Export from contacts", image: ContactImage.bookUser.rawValue)
                            .font(.custom(Gilroy.medium.rawValue, size: 18))
                            .foregroundColor(Color(red: 0.01, green: 0.37, blue: 0.99))
                            .frame(maxWidth: UIScreen.main.bounds.width * 1 ,alignment: .leading)
                            .padding(.top)
                            .padding(.bottom, 5.5)
                            .overlay(
                                VStack() {
                                    Spacer()
                                    Rectangle()
                                        .frame(height: 1)
                                }
                            )
                }
                .onReceive([self.contact].publisher.first()) { value in
                    if let contact = value {
                        self.fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
                        self.phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                        if self.email.isEmpty {
                            self.email = contact.emailAddresses.first?.value as String? ?? ""
                        }
                        self.pastedNumber = true
                    }
                }
            }
            Spacer()
            
            Button {
                if fullName.isEmpty {
                    showFullNameEmptyError = true
                } else {
                    showFullNameEmptyError = false
                }
                
                if email.isEmpty {
                    showEmailEmptyError = true
                } else {
                    showEmailEmptyError = false
                }
                
                if fullName.isEmpty || email.isEmpty {
                    showFieldsEmptyError = true
                } else {
                    showFieldsEmptyError = false
                    viewModel.sendContactRequest(fullName: fullName, phoneNumber: phoneNumber, email: email) { success, error in
                        if let error = error {
                            switch error {
                            case .contactAdded(let title, let description):
                                print("Error: \(title) - \(description)")
                                titleMessage = title
                                descriptionMessage = description
                                showMenuExist = true
                                showTabBar = false
                            case .addingSelf(let title, let description):
                                print("Error: \(title)")
                                titleMessage = title
                                descriptionMessage = description
                                showMenuExist = true
                                showTabBar = false
                            case .limitReached(let title, _):
                                print("Error: \(title)")
                                showMenuExist = false
                                showTabBar = false
                            case .alreadySent(title: let title, description: let description):
                                titleMessage = title
                                descriptionMessage = description
                                showMenuExist = true
                                showTabBar = false
                            }
                            
                        } else {
                            if success {
                                showMenuExist = true
                                showTabBar = false
                                titleMessage = "Add request is sent"
                                descriptionMessage = "Once user accepts your add request you will be able to send emergency live streaming"
                            } else {
                                showMenuMissing = true
                                showTabBar = false
                            }
                        }
                    }
                }
                UIApplication.shared.hideKeyboard()
            } label: {
                Text("Save")
                    .foregroundColor(.white)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.size.height / 15.5)
                    .background(Color.customPrimary)
                    .cornerRadius(18)
            }
            .padding(.bottom, 96)
        }
        .fullScreenCover(isPresented: $viewModel.showLimitExceededAlert) {
            LimitExceededAlert()
                .environmentObject(entitlementManager)
                .environmentObject(purchaseManager)
        }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 16)
        .overlay (
            VStack(spacing: 4) {
                Spacer()
                if showMenuMissing {
                    DropdownMenuMissing(showMenuMissing: $showMenuMissing, showTabBar: $showTabBar).offset(y: showMenuMissing ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30: UIScreen.main.bounds.height)
                }
                if showMenuExist {
                    DropdownMenuExist(showMenuExist: $showMenuExist, showTabBar: $showTabBar, title: titleMessage, description: descriptionMessage).offset(y: showMenuExist ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30: UIScreen.main.bounds.height)
                }
            }
            .background(Color(UIColor.black.withAlphaComponent(showMenuMissing || showMenuExist ? 0.5 : 0)).edgesIgnoringSafeArea(.all))
        )
        .onAppear {
            showTabBar = true
        }
    }
    
    private var header: some View {
        HStack(spacing: 0) {
            Button {
                showMenuContactOptions = false
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(ProfileIcons.arrowBack.rawValue)
                    .imageScale(.large)
                    .frame(width: 35, height: 30, alignment: .leading)
            }
            Spacer()
        }
        .overlay(
            Text("Add contact")
                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
        )
    }
}
struct ContactsViewPrevвыфiew: PreviewProvider {
    static var previews: some View {
        AddContactView(showTabBar: .constant(true), showContactMenu: .constant(false))
    }
}


