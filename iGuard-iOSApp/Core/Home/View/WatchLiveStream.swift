//  WatchLiveStream.swift
//  iGuard-iOSApp
//  Created by Aidar Asanakunov on 13/6/23.

import SwiftUI
import Kingfisher

struct WatchLiveStream: View {
    @State var channelName = ""
    @State var isAudiance = true
    @State var broadcasterData: BroadcasterData?
    @StateObject var viewModel = ContactsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var elapsedTime: TimeInterval = 0
    @State var volumeOn = true
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .top) {
            AgoraViewerHelper.agview
                .background(Color.black)
                .ignoresSafeArea()
            if !viewModel.getEndStatus {
                if viewModel.avatarString != nil {
                    if #available(iOS 15, *) {
                        ZStack(alignment: .center) {
                            Color.black
                                .ignoresSafeArea()
                            ProgressView()
                                .tint(.white)
                        }
                        AsyncImage(url: viewModel.avatarUser) { image in
                                image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .ignoresSafeArea()
                                .frame(maxWidth: UIScreen.main.bounds.width,
                                       maxHeight: UIScreen.main.bounds.height)
                            } placeholder: {
                                ProgressView()
                                    .tint(.white)
                            }
                            .background(Color.black)
                            .blur(radius: 7)
                    } else {
                        RemoteImage(imageUrl: viewModel.avatarString!)
                            .blur(radius: 3)
                    }
                } else {
                    EndBackgroundView()
                        .ignoresSafeArea()
                }
            }
            if viewModel.getStartStatus {
                ZStack {
                    Color.backgroundLightGreen
                        .ignoresSafeArea()
                    ProgressView()
                        .foregroundColor(.white)
                }
            }
            header
            if !viewModel.getEndStatus {
                endOfStream
            }
        }
        .onAppear {
            viewModel.fetchBroadcasterData()
            Task {
                await viewModel.fetchData(channelName: channelName)
                viewModel.joinChannel(channelName: channelName, streamType: isAudiance)
                viewModel.getEndOfStreamStatus(channelName: channelName)
                if !isAudiance {
                    viewModel.acquireRequest(channelName: channelName)
                }
            }
        }
        .onReceive(timer) { _ in
            elapsedTime += viewModel.getEndStatus ? 1 : 0
                }
        .onDisappear {
            AgoraViewerHelper.agview.viewer.rtcEngine.enableAudio()
        }
        .onAppear{
            getTime()
        }
        .onChange(of: AgoraViewerHelper.agview.viewer.agConnection.channel?.count) { newValue in
            if AgoraViewerHelper.agview.viewer.agConnection.channel == nil && isAudiance {
                viewModel.getStartStatus = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    viewModel.getStartStatus = false
                }
            }
        }
        .onChange(of: viewModel.getEndStatus) { newValue in
            if !newValue && !isAudiance {
                AgoraViewerHelper.agview.viewer.leaveChannel()
            }
        }
        .onChange(of: NavigationManager.shared.isOpenLiveStream) { newValue in
            if !newValue {
                viewModel.stopRequest()
            }
        }
    }
    
    func getTime() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 4)
        let getTimeUSTZ = dateFormatter.date(from: dateFormatter.string(from: currentDate))
        
        if let date = dateFormatter.date(from: broadcasterData?.time ?? "2023-06-15 10:30:00") {
            elapsedTime = getTimeUSTZ?.timeIntervalSince(date) ?? currentDate.timeIntervalSince(date)
        } else {
            elapsedTime = currentDate.timeIntervalSince(Date())
        }
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
                    if viewModel.avatarString != nil {
                        Button {
                            print("pressed")
                        } label: {
                            KFImage(viewModel.avatarUser)
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
                        Text(viewModel.fullName ?? "Alikhan Tursunbekov")
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
                            AgoraViewerHelper.agview.viewer.rtcEngine.disableAudio()
                            volumeOn = false
                        } else {
                            AgoraViewerHelper.agview.viewer.rtcEngine.enableAudio()
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
    
    var endOfStream: some View {
        ZStack(alignment: .top) {
            ZStack  {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(Color.blackAlpha60)
                    .frame(width:
                            UIScreen.main.bounds.width * (370 / 414), height: UIScreen.main.bounds.height * (134 / 896))
                VStack(spacing: 14) {
                    Text("Live has ended")
                        .foregroundColor(.white)
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18)
                        )
                    Button {
                        leaveLiveStream()
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.white)
                            .frame(width:
                                    UIScreen.main.bounds.width * (160 / 414), height: UIScreen.main.bounds.height * (48 / 896))
                            .overlay(
                                Text("Close")
                                    .foregroundColor(.black)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: 18)
                                         )
                            )
                        
                    }
                }
            }
            .padding(.top, UIScreen.main.bounds.height * (162 / 896))
        }
    }
    
    func leaveLiveStream() {
        if !isAudiance {
            viewModel.stopRequest()
        }
        AgoraViewerHelper.agview.viewer.leaveChannel()
        presentationMode.wrappedValue.dismiss()
    }
}


struct WatchLiveStream_Previews: PreviewProvider {
    static var previews: some View {
        WatchLiveStream()
    }
}
