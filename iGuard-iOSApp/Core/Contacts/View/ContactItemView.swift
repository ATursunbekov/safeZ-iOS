//
//  ContactObject.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 1/6/23.
//

import SwiftUI
import Kingfisher

struct ContactItemView: View {
    @EnvironmentObject private var viewModel: ContactsViewModel
    @Binding var showDropdownMenu: Bool
    @Binding var showTabBar: Bool
    let contactModel: ContactModel
    let didSelectContact: (ContactModel) -> Void
    
    var body: some View {
        HStack(spacing: 24) {
            if let image = contactModel.image {
                KFImage(URL(string: image))
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width * 0.13, height: UIScreen.main.bounds.width * 0.13)
                    .cornerRadius(15.31)
            } else {
                RoundedRectangle(cornerRadius: 15.31)
                    .fill(Color.backgroundForNotifications)
                    .frame(width: UIScreen.main.bounds.width * 0.13, height: UIScreen.main.bounds.width * 0.13)
                        .overlay (
                            Image(ProfileIcons.profileAvatar.rawValue)
                                .resizable()
                                .frame(width: 32, height: 32)
                        )
            }
            VStack(alignment: .leading) {
                Text(contactModel.fullName.capitalized)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 16))
                    .padding(.top, !contactModel.phoneNumber.isEmpty ? 0 : 10)
                HStack {
                    if !contactModel.phoneNumber.isEmpty {
                        Image(ContactImage.call.rawValue)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    Text(contactModel.phoneNumber)
                        .font(.custom(Gilroy.regular.rawValue, size: 14))
                        .foregroundColor(.secondaryText)
                }
            }
            Spacer()
            Button {
                showDropdownMenu = true
                showTabBar = false
                didSelectContact(contactModel)
            } label: {
                Image(ContactImage.circles.rawValue)
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            viewModel.updatePhotoContacts(contactModel: contactModel)
        }
    }
}
