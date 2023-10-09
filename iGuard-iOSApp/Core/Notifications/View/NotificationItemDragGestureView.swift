//
//  NotificationItemDragGestureView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 18/4/23.
//

import SwiftUI

struct NotificationItemDragGestureView: View {
    @ObservedObject var notificationViewModel: NotificationViewModel
    let notificationModel: NotificationModel
    @GestureState private var slideOffset = CGSize.zero
    @State private var positionX: CGFloat = 0
    @State private var deleteButtonIsHidden: Bool = true
    
    var body: some View {
        ZStack {
            swipeToDelete
            deleteButton
        }
            .onAppear {
                notificationViewModel.updatePhotoNotifications(notificationModel: notificationModel)
            }
    }
    private var swipeToDelete: some View {
       NotificationItemView(notificationModel: notificationModel)
            .offset(x: slideOffset.width + positionX)
            .gesture(DragGesture()
                .updating($slideOffset, body: { dragValue, slideOffset, transaction in
                    if dragValue.translation.width < 0 && dragValue.translation.width > -55 && self.positionX != -55 {
                        slideOffset = dragValue.translation
                    }
                })
                    .onEnded({ dragValue in
                        if dragValue.translation.width < 0 {
                            withAnimation(.spring()) {
                                self.positionX = -70
                                self.deleteButtonIsHidden = false
                            }
                        } else {
                            withAnimation(.spring()) {
                                self.positionX = 0
                                self.deleteButtonIsHidden = true
                            }
                        }
                    })
            )
            .animation(.spring())
    }
    
    @ViewBuilder private var deleteButton: some View {
            if !deleteButtonIsHidden {
                HStack(spacing: 0) {
                    Spacer()
                    Button(action: {
                        deleteItem()
                    }, label: {
                        Image(ProfileIcons.delete.rawValue)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    })
                    .padding(.horizontal)
                    .frame(width: 55)
                    .frame(maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.backgroundForDelete)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 15))
                    .onTapGesture {
                        deleteItem()
                    }
                }
                .padding(.trailing, 16)
            }
        }
    
    private func deleteItem() {
        notificationViewModel.deleteItem(notificationModel)
    }
}
struct GesturePreview: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
