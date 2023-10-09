//  NotificationView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 17/4/23.

import SwiftUI

struct NotificationView: View {
    @StateObject private var notificationViewModel =  NotificationViewModel()
    @StateObject private var navigationManager = NavigationManager.shared
    @Environment (\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack() {
            header
            if notificationViewModel.notificationArray.isEmpty {
                Spacer()
                EmptyScreenView(image: ContactImage.emptyNotifications.rawValue, titleText: "No notifications", secText: "Any new alerts will appear here", width: 20, height: 23)
                Spacer()
            } else {
                ScrollView() {
                    let chunkedMessage = notificationViewModel.notificationArray.chunked(by: {$0.date.dateValue().isSameDay(as: $1.date.dateValue())})
                    ForEach(chunkedMessage.indices, id: \.self) { index in
                        Text(chunkedMessage[index].first?.date.dateValue().formattedDate() ?? "")
                            .font(.custom(Gilroy.regular.rawValue, size: 14))
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                            .padding(.top, 31)
                            .padding(.bottom, 17)
                        VStack(spacing: 18) {
                            ForEach(chunkedMessage[index].uniqued(on: {$0.id})) { message in
                                NotificationItemDragGestureView(notificationViewModel: notificationViewModel, notificationModel: message)
                            }
                        }
                    }
                }
            }
        }
        .background(
            ShapeCircle(arcHeight: 150, arcPosition: .down)
                .fill(Color.backgroundCircleSplash)
                .frame(height: UIScreen.main.bounds.height * 0.85)
                .ignoresSafeArea()
            ,alignment: .top
        )
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                notificationViewModel.updateIsUnread()
            }
        }
        .onDisappear {
            notificationViewModel.listener?.remove()
        }
    }
    
    private var header: some View {
        HStack(spacing: 0) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(ProfileIcons.arrowBack.rawValue)
                    .frame(width: 35, height: 30, alignment: .leading)
            }
            Spacer()
        }
        .overlay(
            Text("Notifications")
                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
        )
        .padding(.leading, 16)
    }
}
