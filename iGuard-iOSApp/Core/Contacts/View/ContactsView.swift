//  ContactsView.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 16/4/23.

import SwiftUI
import Introspect

struct ContactsView: View {
    @EnvironmentObject private var viewModel: ContactsViewModel
    @State private var selectedContact: ContactModel? = nil
    @Binding private var showTabBar: Bool
    @State private var showMenuContactOptions = false
    @State private var showMenuDelete = false
    @State private var searchText = ""
    @State private var uiTabarController: UITabBarController?
    @State private var noContacts = false
    
    
    init(showTabBar: Binding<Bool>) {
        _showTabBar = showTabBar
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: Gilroy.semiBold.rawValue, size: 18)!]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                VStack {
                    if viewModel.contacts.isEmpty {
                        Spacer()
                        EmptyScreenView(image: ContactImage.emptyContacts.rawValue, titleText: "No contacts yet", secText: "You haven’t added any contact yet", width: 18, height: 22)
                        Spacer()
                        NavigationLink {
                            AddContactView(showTabBar: $showTabBar, showContactMenu: $showMenuContactOptions)
                        } label: {
                            Text("Add contact")
                                .foregroundColor(.white)
                                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                                .frame(maxWidth: .infinity)
                                .frame(height: UIScreen.main.bounds.size.height / 15.5)
                                .background(Color.customPrimary)
                                .cornerRadius(18)
                        }
                        .padding(.bottom, UIScreen.main.bounds.size.height * (152 / 896))
                        .padding(.horizontal, 22)
                    }
                    
                    else {
                        SearchBarView(searchText: $searchText)
                            .padding(.top, UIScreen.main.bounds.height * (34 / 896))
                            .padding(.bottom, UIScreen.main.bounds.height * (43 / 896))
                        ScrollView() {
                            VStack(spacing: 30) {
                                ForEach(filteredContacts) { contact in
                                    ContactItemView(showDropdownMenu: $showMenuContactOptions, showTabBar: $showTabBar, contactModel: contact) { contact in
                                        selectedContact = contact
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("My Contacts")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            AddContactView(showTabBar: $showTabBar, showContactMenu: $showMenuContactOptions)
                        } label: {
                            Image(ContactImage.addUser.rawValue)
                        }
                    }
                }
            }
            .overlay (
                VStack {
                    if showMenuContactOptions {
                        Spacer()
                        if let contact = selectedContact {
                            DropdownMenuContactEdit(showTabBar: $showTabBar, showMenuContactOptions: $showMenuContactOptions, showMenuDelete: $showMenuDelete,
                                                    contactModel: contact)
                            .offset(y: showMenuContactOptions ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30: UIScreen.main.bounds.height)
                        }
                    }
                    if showMenuDelete {
                        Spacer()
                        if let contact = selectedContact {
                            DropdownMenuDelete(showMenuDelete: $showMenuDelete, showTabBar: $showTabBar, contactModel: contact).offset(y: showMenuDelete ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30: UIScreen.main.bounds.height)
                        }
                    }
                }
                    .background(Color(UIColor.black.withAlphaComponent(showMenuContactOptions || showMenuDelete ? 0.5 : 0)).edgesIgnoringSafeArea(.all))
            )
            .overlay (
                Group {
                    if filteredContacts.isEmpty  && !viewModel.contacts.isEmpty {
                        EmptyScreenView(image: ContactImage.emptyContacts.rawValue, titleText: "No contacts found", secText: "", width: 18, height: 22)
                    }
                }
            )
            .onAppear {
                showMenuContactOptions = false
            }
        }
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
            uiTabarController = UITabBarController
        }.onDisappear{
            uiTabarController?.tabBar.isHidden = false
        }
        .ignoresSafeArea()
    }
    
    private var filteredContacts: [ContactModel] {
        if searchText.isEmpty {
            return viewModel.contacts
        } else {
            let filtered = viewModel.contacts.filter { contact in
                contact.fullName.localizedCaseInsensitiveContains(searchText)
            }
            
            if filtered.isEmpty {
                print("Contact not found")
            }
            
            return filtered
        }
    }
}

struct Contacts_Preview: PreviewProvider {
    static var previews: some View {
        ContactsView(showTabBar: .constant(false))
            .environmentObject(ContactsViewModel())
    }
}
