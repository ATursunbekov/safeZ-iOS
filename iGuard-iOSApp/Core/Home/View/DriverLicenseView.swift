//  DriverLicenseView.swift
//  iGuard-iOSApp
//  Created by Nurzhan Ababakirov on 25/4/23.
import SwiftUI
import LocalAuthentication
import Kingfisher

struct DriverLicenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var viewModel: HomeViewModel
    @EnvironmentObject var networkMonitor: NetworkMonitor
    let driverLicenseModel: DriverLicenseModel
    let isSecondCard: Bool
    @State private var selection = 0
    @State private var scale: CGFloat = 1.0
    @State private var isFaceIDAuthenticated = false
    @State private var showNetworkAlert = false
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black.ignoresSafeArea()
            TabView(selection: $selection) {
                DriverLicenseInfoView(driverLicenseModel: driverLicenseModel)
                    .tag(0)
                    .padding()
                ForEach(0..<(viewModel.imageURLs.count > 2 ? 2 : viewModel.imageURLs.count), id: \.self) { index in
                    KFImage(URL(string: viewModel.imageURLs[index]))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: UIScreen.main.bounds.width)
                        .tag(index + 1)
                }
            }
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * (800 / 896))
            .rotationEffect(.degrees(90))
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .scaleEffect(scale)
            .gesture(MagnificationGesture().onChanged { value in
                scale = value.magnitude
            }
            .onEnded { value in
                if scale > 1.5 {
                    scale = 1.0
                }
            })
            HStack() {
                ForEach(0..<(viewModel.imageURLs.count > 2 ? 3 : viewModel.imageURLs.count + 1), id: \.self) { index in
                    if selection == index {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 8, height: 4)
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundColor(.gray)
                    }
                }
            }
            .offset(y: UIScreen.main.bounds.width * (170 / 414))
            .rotationEffect(.degrees(90))
        }
        .onChange(of: NavigationManager.shared.broadcasterStreamOn, perform: { newValue in
            if !newValue {
                FaceIDAuthenticationManager.authenticate { success in
                    if success {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        })
        .overlay(
            Button(action: {
                if isSecondCard {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    if networkMonitor.isConnected {
                        FaceIDAuthenticationManager.authenticate { success in
                            if success {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } else {
                        showNetworkAlert = true
                    }
                }
            }) {
                Image(LiveStreamImage.closeScreen.rawValue)
                    .resizable()
                    .frame(width: 15, height: 15)
                    .padding()
                    .background(.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .foregroundColor(.white)
            .offset(x: UIScreen.main.bounds.width / 2 - 24, y: -30)
            
            , alignment: .bottom
        )

    }

}
