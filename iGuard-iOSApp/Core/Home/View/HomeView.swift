import SwiftUI
import Kingfisher
import FirebaseAuth

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var entitlementManager = EntitlementManager()
    @EnvironmentObject private var viewModel: HomeViewModel
    @StateObject private var notificationViewModel = NotificationViewModel()
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var monitorNetwork = NetworkMonitor()
    @Binding var selectedTab: Tabs
    @Binding var show: Bool
    @State private var showUnlock = false
    @State private var showLiveStreamSheet = false
    @State private var didUnlock = false
    @State private var isPresented = false
    @State private var showUserPhoto = false
    @State private var showToggleForSendingLocation = false
    @State private var startInteractiveLive = false
    @State private var showAlert = false
    private let storeKitViewModel = StoreKitViewModel()
    
    private var userLatitude: Double {
        return locationManager.lastLocation?.coordinate.latitude ?? 0.0
    }
    private var userLongitude: Double {
        return locationManager.lastLocation?.coordinate.longitude ?? 0.0
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    AgoraViewerHelper.agview
                        .ignoresSafeArea()
                    Color.white
                    VStack {
                        header
                        VStack(spacing: 50) {
                            secondOptionCard
                            firstOptionCard
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 22)
                    .edgesIgnoringSafeArea(.bottom)
                    .environmentObject(viewModel)
                    .environmentObject(monitorNetwork)
                }
                .onChange(of: NavigationManager.shared.broadcasterStreamOn, perform: { newValue in
                    didUnlock = newValue
                    print("Streaming ended to switch different screen!!!!!")
                })
                .onChange(of: didUnlock) { newValue in
                    if newValue {
                        viewModel.regeneateUUID()
                        Task {
                            await viewModel.fetchAgoraToken()
                            viewModel.acquireRequest()
                            viewModel.joinChannel()
                            viewModel.sendNotificationMyContacts(streamType: true)
                        }
                    } else {
                        if viewModel.startResponse?.resourceId != nil && viewModel.startResponse?.sid != nil {
                            Task {
                                viewModel.stopRequest()
                                AgoraViewerHelper.agview.viewer.leaveChannel()
                            }
                            print("Recording saved!!!")
                        } else {
                            print("nil sid and source!")
                        }
                    }
                }
                .fullScreenCover(isPresented: $navigationManager.isOpenLiveStream) {
                    if startInteractiveLive {
                        InteractiveLive(channelName: UUID().uuidString) //MARK: TODO
                            .environmentObject(viewModel)
                    } else {
                        WatchLiveStream(channelName: navigationManager.channelName, isAudiance: navigationManager.isHiddenStream ,broadcasterData: navigationManager.broadcasterData)
                    }
                }
                .fullScreenCover(isPresented: $navigationManager.isOpenMapView) {
                    MapView(latitude: navigationManager.latitude, longitude: navigationManager.longitude)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Location Permission"),
                message: Text("If you want to send your location, you must enable permissions in settings, or it will be sent without location data."),
                primaryButton: .default(Text("Open Settings"), action: openAppSettingsForLocationPermission),
                secondaryButton: .cancel()
            )
        }
        .background (
            VStack {
                Spacer()
                ShapeCircle(arcHeight: UIScreen.main.bounds.height * 0.1875, arcPosition: .up)
                    .fill(Color.backgroundLightPurple)
                    .frame(height: UIScreen.main.bounds.height * 0.35)
            }
            ,alignment: .bottom
        )
        .onAppear {
            viewModel.fetchData()
            viewModel.checkIsUnreadMethod()
            startInteractiveLive = false
            
        }
        .onDisappear {
            startInteractiveLive = false
            viewModel.removeListener()
        }
    }
    
    var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    if let avatarUserURL = viewModel.avatarUser {
                        KFImage(avatarUserURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .cornerRadius(20)
                            .shadow(color: .shadowImage, radius: 12, y:  10)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .frame(width: 60, height: 60)
                            .overlay (
                                Image(ProfileIcons.profileAvatar.rawValue)
                                    .resizable()
                                    .frame(width: 42, height: 42)
                            )
                            .shadow(color: .shadowImage, radius: 12, y:  10)
                    }
                }
                .onTapGesture {
                    selectedTab = .profile
                }
                VStack(alignment: .leading) {
                    Text("Welcome back,")
                        .font(.custom(Gilroy.regular.rawValue, size: 18))
                        .foregroundColor(.secondaryText)
                    Text("\(viewModel.currentUserFullName.capitalized)!")
                        .font(.custom(Gilroy.extraBold.rawValue, size: 24))
                }
            }
            Spacer()
            NavigationLink {
                NotificationView()
            } label: {
                Image(viewModel.checkIsUnread ? HomeImage.notification.rawValue : HomeImage.notification1.rawValue)
            }
            NavigationLink(destination: NotificationView(), isActive: $navigationManager.isOpenNotificationView) {
                EmptyView()
            }
        }
        .padding(.top, 0)
    }
    var firstOptionCard: some View {
        ZStack(alignment: .center) {
            if viewModel.infoDriverLicense.isEmpty || viewModel.infoDriverLicense[0].state == "" {
                Image(HomeImage.driverLicenseCard.rawValue)
                    .resizable()
                    .scaledToFill()
                    .frame(height: UIScreen.main.bounds.height * 0.27)
                    .shadow(color: .shadowTFLogin, radius: 10, x: 13, y: 16)
            } else {
                getUsersFlagImage
            }
            VStack(spacing: 20) {
                VStack(spacing: UIScreen.main.bounds.height * 0.04) {
                    if showUnlock {
                        SwipeToUnlockHomeView()
                            .onSwipeSuccess {
                                self.didUnlock = true
                                NavigationManager.shared.broadcasterStreamOn = true
                                self.showUnlock = false
                                if showToggleForSendingLocation {
                                    switch locationManager.locationStatus {
                                    case .authorizedWhenInUse, .authorizedAlways:
                                        locationManager.sendNotificationMyContacts(latitude: userLatitude, longitude: userLongitude)
                                    default:
                                        print("unknown")
                                    }
                                }
                            }
                            .transition(AnyTransition.scale.animation(Animation.spring(response: 0.3, dampingFraction: 0.5)))
                    }
                }
            }
        }
        .overlay(
            HStack(spacing: 14) {
                Spacer()
                sendLocationButton
                Toggle(isOn: $showToggleForSendingLocation) {
                    
                }
                .onChange(of: showToggleForSendingLocation) { newValue in
                    if newValue {
                        switch locationManager.locationStatus {
                        case .notDetermined:
                            locationManager.locationManager.requestWhenInUseAuthorization()
                        case .denied:
                            showAlert = true
                        default:
                            print("unknown")
                        }
                    }
                }
                .toggleStyle(ColoredToggleStyle())
            }
                .padding(.top, 13)
                .padding(.trailing, 10)
            ,alignment: .top
        )
        
        .fullScreenCover(isPresented: $didUnlock, onDismiss: {
            self.showUnlock = true
            self.showToggleForSendingLocation = false
        }, content: {
            DriverLicenseView(driverLicenseModel: viewModel.infoDriverLicense[0], isSecondCard: false)
        })
        .onAppear {
            if let email = Auth.auth().currentUser?.email, email.contains("test@deveem.io") {
                UserDefaults.standard.set(false, forKey: "isTrialActive")
            }
            
            self.showUnlock = true
        }
        .padding(.top, 15.5)
    }
    var secondOptionCard: some View {
        Group {
            if viewModel.infoDriverLicense.isEmpty || viewModel.infoDriverLicense[0].state == "" {
                Image(HomeImage.driverLicenseCard.rawValue)
                    .resizable()
                    .scaledToFill()
                    .frame(height: UIScreen.main.bounds.height * 0.27)
                    .shadow(color: .shadowTFLogin, radius: 10, x: 13, y: 16)
            } else {
                Image("safeZ")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width * (370 / 414), height: UIScreen.main.bounds.height * (237 / 896))
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(15)
                    .shadow(color: .shadowTFLogin, radius: 10, x: 13, y: 16)
            }
        }
        .onTapGesture {
            startInteractiveLive = true
            navigationManager.isOpenLiveStream = true
            Task {
                viewModel.regeneateUUID()
                await viewModel.fetchAgoraToken()
                viewModel.acquireRequest()
                viewModel.joinChannel()
                viewModel.sendNotificationMyContacts(streamType: false)
            }
        }
        .fullScreenCover(isPresented: $showLiveStreamSheet) {
            DriverLicenseView(driverLicenseModel: viewModel.infoDriverLicense[0], isSecondCard: true)
        }
    }
    
    var getUsersFlagImage: some View {
        ZStack {
            Image(HomeViewModel.lowercaseFirstLetterAndRemoveWhitespace(viewModel.infoDriverLicense[0].state))
                .resizable()
                .frame(width: UIScreen.main.bounds.width * (370 / 414), height: UIScreen.main.bounds.height * (237 / 896))
                .aspectRatio(contentMode: .fill)
                .cornerRadius(15)
                .shadow(color: .shadowTFLogin, radius: 10, x: 13, y: 16)
                .opacity(0.6)
        }
    }
    
    var sendLocationButton : some View {
        ZStack {
            Capsule()
                .fill(Color.white)
                .frame(width: 47, height: 35)
            Image(systemName: "location.fill")
                .font(.system(size: 20.32))
                .foregroundColor(.customPrimary)
        }
    }
    
    func openAppSettingsForLocationPermission() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings)
            showToggleForSendingLocation = false
        }
    }
}


struct ColoredToggleStyle: ToggleStyle {
    var onColor = Color.customPrimary
    var offColor = Color.black
    var thumbColor = Color.white
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label // The text (or view) portion of the Toggle
            
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(configuration.isOn ? onColor : offColor)
                .frame(width: 50, height: 29)
                .overlay(
                    Circle()
                        .fill(thumbColor)
                        .shadow(radius: 1, x: 0, y: 1)
                        .padding(1.5)
                        .offset(x: configuration.isOn ? 10 : -10))
                .animation(Animation.easeInOut(duration: 0.2))
                .onTapGesture { configuration.isOn.toggle() }
        }
        .font(.title)
    }
}


struct HomeView_Preview: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(.chat), show: .constant(true))
            .environmentObject(HomeViewModel())
    }
}
