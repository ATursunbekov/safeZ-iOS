import SwiftUI

struct EditContactView: View {
    @EnvironmentObject private var viewModel: ContactsViewModel
    let contactModel: ContactModel
    @Binding private var showTabBar: Bool
    @Binding private var showMenuDelete: Bool
    @Binding private var showMenuContactOptions: Bool
    @State private var fullName: String
    @State private var phoneNumber: String
    @State private var email: String
    @State private var isPastedNumber = false
    @Environment(\.presentationMode) var presentationMode
    
    init(showTabBar: Binding<Bool>, showMenuContactOptions: Binding<Bool>,showMenuDelete: Binding<Bool>,fullName: String, phoneNumber: String, email: String, contactModel: ContactModel) {
        _showTabBar = showTabBar
        _showMenuDelete = showMenuDelete
        _showMenuContactOptions = showMenuContactOptions
        _fullName = State(initialValue: fullName)
        _phoneNumber = State(initialValue: phoneNumber)
        _email = State(initialValue: email)
        self.contactModel = contactModel
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: Gilroy.semiBold.rawValue, size: 18)!]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 30) {
                    ContactTextField(placeholder: "FullName", text: $fullName, isEditable: true, showError: false, autocapitalizationType: .words)
                    TextFieldNumber(placeholder: "Phone Number", number: $phoneNumber, pastedNumber: $isPastedNumber, showError: false)
                    ContactTextField(placeholder: "Email Address", text: $email, isEditable: false, showError: false, autocapitalizationType: .none)
                    Spacer()
                    Button {
                        showMenuContactOptions = false
                        withAnimation(.spring()) {
                            viewModel.editContact(fullName: fullName, phoneNumber: phoneNumber, email: email)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Text("Done")
                            .foregroundColor(.white)
                            .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.main.bounds.size.height / 15.5)
                            .background(Color.customPrimary)
                            .cornerRadius(18)
                            .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                    }
                    .padding(.bottom, 60)
                }
                .padding(.bottom, 36)
                .padding(.horizontal, 22)
                .padding(.top, 35)
            }
            .toolbar {
                Button {
                    showTabBar = false
                    showMenuDelete = true
                } label: {
                    Image(ProfileIcons.delete.rawValue)
                        .foregroundColor(.red)
                }
            }
            .font(.custom(
                Gilroy.regular.rawValue,
                fixedSize: 18))
            .navigationTitle("Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: buttonBack)
        }
        .navigationBarBackButtonHidden(true)
        .overlay(
            VStack {
                Spacer()
                DropdownMenuDelete(showMenuDelete: $showMenuDelete, showTabBar: $showTabBar, contactModel: contactModel).offset(y: self.showMenuDelete ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30: UIScreen.main.bounds.height)
            }
                .background(Color(UIColor.black.withAlphaComponent(self.showMenuDelete ? 0.5 : 0)).edgesIgnoringSafeArea(.all))
                .animation(.easeInOut(duration: 0.5))
        )
        .onAppear {
            showTabBar = true
        }
    }
    
    var buttonBack: some View {
        Button {
            showMenuContactOptions = false
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Image(ProfileIcons.arrowBack.rawValue)
                .foregroundColor(.black)
        }
    }
    
}
