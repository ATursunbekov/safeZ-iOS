//
//  NotificationItemView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 17/4/23.
//

import SwiftUI
import Kingfisher

struct NotificationItemView: View {
    
    let notificationModel: NotificationModel
    @StateObject private var viewModel = NotificationViewModel()
    @StateObject private var navigationManager = NavigationManager.shared
    
    var body: some View {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(height: UIScreen.main.bounds.height * 0.12)
                HStack(spacing: 12) {
                    if let imageURL = notificationModel.imageURL {
                        KFImage(URL(string: imageURL))
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width * 0.13, height: UIScreen.main.bounds.width * 0.13)
                            .cornerRadius(15.31)
                            .shadow(color: .shadowTFLogin, radius: 30, x: 14.22, y: 17.5)
                    } else {
                        RoundedRectangle(cornerRadius: 15.31)
                            .fill(Color.backgroundForNotifications)
                            .frame(width: UIScreen.main.bounds.width * 0.13, height: UIScreen.main.bounds.width * 0.13)
                            .overlay(
                                Image(ProfileIcons.profileAvatar.rawValue)
                                .resizable()
                                .frame(width: 32, height: 32)
                            )
                            .shadow(color: .shadowTFLogin, radius: 30, x: 14.22, y: 17.5)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(notificationModel.fullName)
                            .font(.custom(Gilroy.semiBold.rawValue, size: 14)).tracking(-0.17)
                        Text(notificationModel.requestMessage)
                            .font(.custom(Gilroy.regular.rawValue, size: 13)).tracking(-0.17)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        HStack(spacing: 12) {
                            if notificationModel.status == "pending" {
                                Button {
                                    viewModel.acceptRequest(notificationModel: notificationModel)
                                    viewModel.sendAcceptedNotification(notificationModel: notificationModel)
                                } label: {
                                    Capsule()
                                        .fill(Color.customPrimary)
                                        .frame(width: 64, height: 22)
                                        .overlay(
                                            Text("Accept")
                                                .font(.custom(Gilroy.medium.rawValue, size: 12))
                                                .foregroundColor(.white)
                                        )
                                }
                                Button {
                                    viewModel.rejectRequest(notificationModel: notificationModel)
                                    viewModel.sendRejectedNotification(notificationModel: notificationModel)
                                } label: {
                                    Capsule()
                                        .fill(Color.errorRed)
                                        .frame(width: 64, height: 22)
                                        .overlay(
                                            Text("Reject")
                                                .font(.custom(Gilroy.medium.rawValue, size: 12))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            else if notificationModel.status == "location" {
                                if let latitude = notificationModel.location?.latitude,
                                   let longitude = notificationModel.location?.longitude {
                                    NavigationLink {
                                        MapView(latitude: latitude, longitude: longitude)
                                    } label: {
                                        Capsule()
                                            .fill(Color.customPrimary)
                                            .frame(width: 50, height: 22)
                                            .overlay(
                                                Text("View")
                                                    .font(.custom(Gilroy.medium.rawValue, size: 12))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                            }
                        }
                        Text(notificationModel.formattedDate)
                            .font(.custom(Gilroy.regular.rawValue, size: 12))
                            .opacity(0.6)
                    }
                    
                    Spacer()
                    if notificationModel.isUnread {
                        Circle()
                            .fill(Color.customPrimary)
                            .frame(width: 8, height: 8)
                            .padding(.trailing)
                    }
                }
                .padding(.leading, 16)
            }
            .fullScreenCover(isPresented: $viewModel.isOpenLiveStream) {
                WatchLiveStream(channelName: viewModel.channelName,
                                broadcasterData: navigationManager.broadcasterData)
                .onAppear {
                    print("click")
                }
            }
            .onTapGesture {
                viewModel.handleNotificationSelection(notification: notificationModel)
            }
        .padding(.horizontal, 16)
    }
}
