//
//  VideoPlayerView.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 23/6/23.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI

struct VideoPlayerScreenView: View {
    
    var selectedVideo: RecordingFetchedData
    @State var player = AVPlayer()
    @Environment (\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .onDisappear {
                    player.pause()
                }
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 20)
//                                .foregroundColor(.blackAlpha60)
//                                .frame(width: 48, height: 48)
                            Image(LiveStream.exitIcon.rawValue)
                                .foregroundColor(.white)
                                .padding()
                       // }
                    }
                    .padding(.top, UIScreen.main.bounds.height * (40 / 844))
                    .padding(.leading, 15)
                    Spacer()
                }
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        .onAppear{
            player = AVPlayer(url: URL(string: selectedVideo.url1)!)
            player.play()
        }
    }
}
