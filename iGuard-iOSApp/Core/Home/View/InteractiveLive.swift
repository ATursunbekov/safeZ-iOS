//
//  InteractiveLive.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 25/8/23.
//

import SwiftUI
import Kingfisher

struct InteractiveLive: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @State var channelName = ""
    @StateObject var viewModel = ContactsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var elapsedTime: TimeInterval = 0
    @State var volumeOn = true
    @State var exitPressed = false
    @State var startStatus = true
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .top) {
            AgoraViewerHelper.agview
                .background(Color.black)
                .ignoresSafeArea()
            header
            if startStatus {
                ZStack {
                    Color.backgroundLightGreen
                        .ignoresSafeArea()
                    ProgressView()
                        .foregroundColor(.white)
                }
            }
        }
        .onReceive(timer) { _ in
            elapsedTime += viewModel.getEndStatus ? 1 : 0
        }
        .onAppear{
            getTime()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                startStatus = false
            }
        }
    }
    
    func getTime() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 4)
        let getTimeUSTZ = dateFormatter.date(from: dateFormatter.string(from: currentDate))
        
        elapsedTime = currentDate.timeIntervalSince(Date())
    }
    
    private func formattedElapsedTime() -> String {
            let seconds = Int(elapsedTime) % 60
            let minutes = Int(elapsedTime) / 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    
    var header: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 12) {
                    if homeViewModel.avatarUser != nil {
                        Button {
                            print("pressed")
                        } label: {
                            KFImage(homeViewModel.avatarUser)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .cornerRadius(20)
                        }
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
                    VStack(alignment: .leading, spacing: 6) {
                        Text(homeViewModel.currentUserFullName)
                            .foregroundColor(viewModel.getStartStatus ? .black : .white)
                            .font(.custom(Gilroy.semiBold.rawValue, size: 22)
                            )
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        HStack {
                            HStack(spacing: 2){
                                Circle()
                                    .foregroundColor(.white)
                                    .frame(width: 6, height: 6)
                                Text("LIVE")//Live
                                    .foregroundColor(.white)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: 14)
                                    )
                            }
                            .frame(minWidth: 50)
                            .frame(minHeight: 25)
                            .background(
                                Capsule()
                                    .foregroundColor(Color("backgroundColorLive"))
                            )
                            Text(formattedElapsedTime())//Time
                                .foregroundColor(.black)
                                .frame(minWidth: 51)
                                .frame(minHeight: 25)
                                .background(
                                    Capsule()
                                        .foregroundColor(.white)
                                )
                                .font(.custom(Gilroy.medium.rawValue, size: 14)
                                )
                        }
                        .frame(minHeight: 25)
                    }
                    Spacer()
                }
                .frame(minWidth: UIScreen.main.bounds.width * (243 / 414))
                Spacer()
            }
            Spacer()
            VStack(alignment: .trailing) {
                    Button {
                        leaveLiveStream()
                        exitPressed = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.blackAlpha60)
                                .frame(width: 48, height: 48)
                            Image(LiveStream.exitIcon.rawValue)
                        }
                    }
                Spacer()
                if viewModel.getEndStatus {
                    Button {
                        if volumeOn {
                            //AgoraViewerHelper.agview.viewer.rtcEngine.disableAudio()
                            AgoraViewerHelper.agview.viewer.setMic(to: false)
                            volumeOn = false
                        } else {
                            //AgoraViewerHelper.agview.viewer.rtcEngine.enableAudio()
                            AgoraViewerHelper.agview.viewer.setMic(to: true)
                            volumeOn = true
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.blackAlpha60)
                                .frame(width: 48, height: 48)
                            Image(volumeOn ? LiveStream.volumeOn.rawValue : LiveStream.volumeOff.rawValue)
                        }
                    }
                    .padding(.bottom, UIScreen.main.bounds.height * (28 / 896))
                }
            }
        }
        .padding(.leading, 30)
        .padding(.trailing, 22)
        .padding(.top, 13)
    }
    
    func leaveLiveStream() {
        homeViewModel.stopRequest()
        AgoraViewerHelper.agview.viewer.leaveChannel()
        presentationMode.wrappedValue.dismiss()
    }
}
