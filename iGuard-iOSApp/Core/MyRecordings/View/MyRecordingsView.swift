//  MyRecordings.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 14/4/23.
import SwiftUI
import AVFoundation
import _AVKit_SwiftUI
import Introspect

struct MyRecordings: View {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    @Environment (\.presentationMode) private var presentationMode
    @State var playVideo = false
    
    @StateObject var viewModel = RecordingViewModel()
    //For progress indicator (loader)
    @State private var selectedVideo: RecordingFetchedData? = nil
    @State private var player: AVPlayer? = nil
    //For deleting videos
    @Binding var showTabBar: Bool
    @State var showDeleteMenu = false
    
    
    var body: some View {
        ZStack {
            VStack {
                header
                    .padding(.top, UIScreen.main.bounds.height * (64 / 844))
            ScrollView(showsIndicators: false) {
                    recordedVideos
                    .padding(.bottom, 100)
                    if viewModel.recordings.isEmpty {
                        Spacer()
                            .frame(height: viewModel.showLoader ? 0 : UIScreen.main.bounds.width * 0.8)
                        ZStack{
                            EmptyScreenView(image: ContactImage.emptyRecordigns.rawValue, titleText: "", secText: "You don’t have any recordings yet", width: 23.8, height: 21)
                            if viewModel.showLoader {
                                Color.white
                                    .ignoresSafeArea()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                //.padding(.bottom, 73)
            }
            .navigationBarHidden(true)
            if viewModel.showLoader {
                ActivityIndicator(style: .medium)
            }
        }
        .ignoresSafeArea()
        .overlay(
            VStack {
                if showDeleteMenu {
                    Spacer()
                    DropDownMenuDeleteRecording(showMenuDelete: $showDeleteMenu, showTabBar: $showTabBar, selectedVideo: selectedVideo!)
                        .offset(y: showDeleteMenu ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30: UIScreen.main.bounds.height)
                        .animation(.easeInOut(duration: 0.1))
                        .transition(.move(edge: .bottom))
                        //.padding(.horizontal,UIScreen.main.bounds.width *  (13 / 390))
                        .frame(maxWidth: UIScreen.main.bounds.width)
                }
            }
                .background(Color(UIColor.black.withAlphaComponent(showDeleteMenu ? 0.5 : 0)).edgesIgnoringSafeArea(.all))
            )
        .onDisappear {
            showTabBar = true
        }
        .environmentObject(viewModel)
        .introspectTabBarController { (UITabBarController) in
            if showDeleteMenu {
                UITabBarController.tabBar.isHidden = true
            } else {
                UITabBarController.tabBar.isHidden = true
            }
        }
    }
    private var header: some View {
        HStack(spacing: 0) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(ProfileIcons.arrowBack.rawValue)
                    .imageScale(.large)
                    .frame(width: 35, height: 30, alignment: .leading)
            }
            .frame(width: 35, height: 30, alignment: .leading)
            Spacer()
        }
        .padding(.leading, 26)
        .overlay(
            Text("My recordings")
                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
        )
    }
    
    var recordedVideos: some View {
        VStack {
            ForEach(viewModel.recordings, id: \.self) { video in
                VStack(spacing: 0) {
                        Rectangle()
                        .foregroundColor(.black)
                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.3)
                        .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 16))
                        .overlay(
                            Capsule()
                                .fill(Color.blackAlpha60)
                                .frame(width: 38, height: 24)
                                .padding(16)
                                .overlay(
                                    Text(video.time)
                                        .foregroundColor(.white)
                                        .font(.custom(Gilroy.semiBold.rawValue, size: 10))
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            , alignment: .top
                        )
                        .overlay(
                            Button {
                                selectedVideo = video
                                playVideo = true
                            } label: {
                                Image(LiveStream.playRecording.rawValue)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.white)
                                    .padding(20)
                            }
                        )
                    ZStack {
                        Rectangle()
                            .fill(Color.white.opacity(1))
                            .clipShape(CustomCorners(corners: [.bottomLeft, .bottomRight], radius: 25))
                            .frame(width: screenWidth * 0.9 ,height: screenHeight * 0.06)
                        HStack() {
                            Text("\(viewModel.getCurrentDate(recDate: video.date)), \(video.size) Mb")
                                .font(.custom(Gilroy.medium.rawValue, size: 14))
                                .foregroundColor(.black)
                            Spacer()
                            HStack(spacing: 12) {
                                Button {
                                    viewModel.isShareSheetShowing = true
                                } label: {
                                    Image(RecordingsImage.shareVideo.rawValue)
                                }
                                Button {
                                    selectedVideo = video
                                    showDeleteMenu = true
                                } label: {
                                    Image(RecordingsImage.deleteVideo.rawValue)
                                }
                                
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 0)
                }
                .fullScreenCover(isPresented: $playVideo) {
                } content: {
                    VideoPlayerScreenView(selectedVideo: selectedVideo ?? video)
                }
                .scaledToFill()
                .padding(.top, 33)
                .shadow(color: Color.shadowTFLogin, radius:10, x: 4, y: 6)
                .sheet(isPresented: $viewModel.isShareSheetShowing) {
                    ShareSheet(activityItems: [URL(string: video.url1)!])
                }
            }
        }
        .onAppear{
            viewModel.retrieveVideos()
        }
    }
}

struct CustomCorners: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Update the controller if needed.
    }
}

struct Dddd: PreviewProvider {
    static var previews: some View {
        MyRecordings( showTabBar: .constant(true))
    }
}
