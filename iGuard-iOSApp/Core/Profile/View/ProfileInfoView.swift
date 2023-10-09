

import SwiftUI
import Kingfisher
import Introspect

struct ProfileInfoView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @StateObject private var homeViewModel = HomeViewModel()
    @Environment (\.presentationMode) var presentationMode
    @Binding var tabBarShow: Bool
    @Binding var show: Bool
    @Binding var showMenuEditPicture: Bool
    
    init(tabBarShow: Binding<Bool>, show: Binding<Bool>, showMenuEditPicture: Binding<Bool>) {
        self._tabBarShow = tabBarShow
        self._show = show
        self._showMenuEditPicture = showMenuEditPicture
        UINavigationBar.setAnimationsEnabled(false)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack() {
                    infoUser
                    ZStack() {
                        background
                    }
                    TabsViews(showTabBar: $tabBarShow)
                }
            }
            .navigationTitle("My Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ProfileEditView(tabBarShow: $tabBarShow, showMenuDelete: $show, showMenuEditPicture: $showMenuEditPicture)
                    } label: {
                        Image(ProfileIcons.edit.rawValue)
                    }
                }
            }
            .onAppear {
                tabBarShow = true
                homeViewModel.fetchData()
                print("OnApear")
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var infoUser: some View {
        VStack(spacing: 23) {
            if let avatarUserURL = homeViewModel.avatarUser {
                KFImage(avatarUserURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(ProfileIcons.addAvatar.rawValue)
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(Color.backgroundCircleSplash)
                    .frame(width: 100, height: 100)
            }
            VStack(spacing: 8) {
                Text(homeViewModel.currentUserFullName.capitalized)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 22))
                Text(homeViewModel.currentUserEmail)
                    .font(.custom(Gilroy.medium.rawValue, size: 12))
                    .accentColor(.black)
            }
        }
        .padding(.top, 40)
    }
    
    private var background: some View {
        GeometryReader { proxy in
            let mult = proxy.safeAreaInsets.bottom == 0 ? 0.9 : 1
            let size = proxy.size.width * 2.5 * mult
            ZStack() {
                Circle()
                    .fill(
                        Color.backgroundCircleSplash
                    )
                    .frame(width: size, height: size)
                    .offset(
                        x: proxy.frame(in: .local).midX - size / 2,
                        y: proxy.frame(in: .local).midY * 0.06)
            }
        }
    }
}
