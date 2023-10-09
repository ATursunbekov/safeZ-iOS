import SwiftUI

struct CustomTabView: View {
    @StateObject var navigationManager = NavigationManager.shared
    @StateObject var locationManager = LocationManager()
    @State private var tabBarShow = true
    @State private var show = false
    @State private var showMenuEditPicture = false
    @StateObject private var contactViewModel = ContactsViewModel()
    
    var body: some View {
        ZStack {
            TabView(selection:  $navigationManager.selectedTab) {
                switch navigationManager.selectedTab {
                case .home:
                    HomeView(selectedTab:  $navigationManager.selectedTab, show: $show)
                case .contact:
                    ContactsView(showTabBar: $tabBarShow)
                        .environmentObject(contactViewModel)
                case .chat:
                    ChatView(showBar: $tabBarShow)
                        .environmentObject(locationManager)
                case .profile:
                    ProfileInfoView(tabBarShow: $tabBarShow, show: $show, showMenuEditPicture: $showMenuEditPicture)
                }
            }
            if tabBarShow {
                TabBarView(selectedTab:  $navigationManager.selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
    }
}
