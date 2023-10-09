//
//  TabsView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 12/4/23.
//

import SwiftUI
struct TabsViews: View {
    @ObservedObject private var profileInfoViewModel = ProfileInfoViewModel()
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var isFaceIDAuthenticated = false
    @State private var isMyRecordings = false
    @State private var isMySubscriptions = false
    @Binding var showTabBar: Bool
    @State private var showWebView = false
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(profileInfoViewModel.profileTabsArray) { tab in
                switch tab.title {
                case "My Recordings":
                    Button {
                       
                                self.isMyRecordings = true
                                self.showTabBar = false
                            
                    } label: {
                        tabView(for: tab)
                    }
                case "My Documents":
                    Button {
                        FaceIDAuthenticationManager.authenticate { result in
                            if result {
                                self.isFaceIDAuthenticated = true
                                self.showTabBar = false
                            }
                        }
                    } label: {
                        tabView(for: tab)
                    }
                case "My Subscription":
                    Button {
                                self.isMySubscriptions = true
                                self.showTabBar = false
                            
                    } label: {
                        tabView(for: tab)
                    }
                case "Settings":
                    NavigationLink(destination: SettingsView()) {
                        tabView(for: tab)
                    }
                case "Terms of use":
                    Button(action: {
                        
                        showWebView = true
                    }) {
                        tabView(for: tab)
                    }
                case "Share":
                    Button(action: ShareHelper().share) {
                        tabView(for: tab)
                    }
                case "Logout":
                    Button(action: {
                        viewModel.deleteFCMTokenFromFirestore()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            viewModel.signOut()
                            resetQuestionLimit()
                        }
                    }) {
                        tabView(for: tab)
                    }
                default:
                    EmptyView()
                }
            }
        }
        .padding(.top, 40)
        .padding(.bottom, 60)
        .fullScreenCover(isPresented: $showWebView) {
            WebViewWrapper(showWebView: $showWebView, urlString: "https://www.iguard.app/termsandconditions")
        }
        .introspectTabBarController { (UITabBarController) in
            if showTabBar {
                UITabBarController.tabBar.isHidden = false
            } else {
                UITabBarController.tabBar.isHidden = true
            }
        }
        .background(
            NavigationLink(destination: SubscriptionView(showTabBar: $showTabBar),
                           isActive: $isMySubscriptions) { EmptyView() }
        )
        .background(
            NavigationLink(destination: MyRecordings(showTabBar: $showTabBar),
                           isActive: $isMyRecordings) { EmptyView() }
        )
        .background(
           // activate link for tapped photo
           NavigationLink(destination: MyDocumentsView(showTabBar: $showTabBar),
              isActive: $isFaceIDAuthenticated) { EmptyView() }
        )
    }
    func resetQuestionLimit() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(0, forKey: "questionCount")
        userDefaults.removeObject(forKey: "lastQuestionDate")
        UserDefaults.standard.removeObject(forKey: "isSubscribed")
    }

    private func tabView(for tab: ProfileModel) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(height: 68)
            HStack(spacing: 24) {
                Circle()
                    .fill(Color.backgroundCircleSplash)
                    .frame(width: 48, height: 48)
                    .padding(.horizontal, 16)
                    .overlay(
                        Image(tab.image)
                    )
                Text(tab.title)
                    .font(.custom(Gilroy.regular.rawValue, size: 14))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 32)
    }
}
