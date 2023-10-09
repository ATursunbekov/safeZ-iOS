
import SwiftUI

enum Tabs: Int {
    case home = 0
    case contact = 1
    case chat = 2
    case profile = 3
}

struct TabBarView: View {
    @Binding var selectedTab: Tabs
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack {
            
            Spacer()
            
            HStack(spacing: 50) {
                Button {
                    selectedTab = .home
                } label: {
                    VStack(spacing: 6) {
                        Image(TabViewIcons.home.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        Text("Home")
                            .font(.custom(Gilroy.semiBold.rawValue, size: 12))
                    }
                    .foregroundColor(selectedTab == .home ? .customPrimary : .customGray)
                }
                Button {
                    selectedTab = .contact
                } label: {
                    VStack(spacing: 6) {
                        Image(TabViewIcons.contact.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        Text("Contact")
                            .font(.custom(Gilroy.semiBold.rawValue, size: 12))
                    }
                    .foregroundColor(selectedTab == .contact ? .customPrimary : .customGray)
                }
                Button {
                    selectedTab = .chat
                } label: {
                    VStack(spacing: 6) {
                        Image(selectedTab == .chat ?  "chatPanteraBlue" :TabViewIcons.chatPantera.rawValue)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 26, height: 26)
                        Text("Chat")
                            .font(.custom(Gilroy.semiBold.rawValue, size: 12))
                    }
                    .foregroundColor(selectedTab == .chat ? .customPrimary : .customGray)
                }
                Button {
                    selectedTab = .profile
                } label: {
                    VStack(spacing: 6) {
                        Image(TabViewIcons.profile.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        Text("Profile")
                            .font(.custom(Gilroy.semiBold.rawValue, size: 12))
                    }
                    .foregroundColor(selectedTab == .profile ? .customPrimary : .customGray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            .background(
                Color.white
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .ignoresSafeArea()
            )
        }
        .shadow(color: .shadowTFLogin, radius: 8, x: -2, y: -4)
    }
}
