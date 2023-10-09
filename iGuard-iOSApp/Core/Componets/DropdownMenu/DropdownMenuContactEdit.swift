import SwiftUI
import Kingfisher

struct DropdownMenuContactEdit: View {
    @Binding var showTabBar: Bool
    @Binding var showMenuContactOptions: Bool
    @Binding var showMenuDelete: Bool
    @State private var offset = CGSize.zero
    let contactModel: ContactModel
    var body: some View {
        VStack(alignment: .leading ,spacing: 25) {
            Capsule()
                .fill(Color.colorDate)
                .frame(width: 40, height: 2)
                .frame(maxWidth: .infinity, alignment: .center)
            VStack(alignment: .leading) {
                HStack(spacing: 24) {
                    if let image = contactModel.image {
                        KFImage(URL(string: image))
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width * 0.13, height: UIScreen.main.bounds.width * 0.13)
                            .cornerRadius(15.31)
                            .shadow(color: Color.shadowTFLogin, radius: 15, x: 13, y: 16)
                    } else {
                        RoundedRectangle(cornerRadius: 15.31)
                            .fill(Color.backgroundForNotifications)
                            .frame(width: UIScreen.main.bounds.width * 0.13, height: UIScreen.main.bounds.width * 0.13)
                                .overlay (
                                    Image(ProfileIcons.profileAvatar.rawValue)
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                )
                                .shadow(color: Color.shadowTFLogin, radius: 15, x: 13, y: 16)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(contactModel.fullName)
                            .font(.custom(Gilroy.semiBold.rawValue, size: 16))
                            .padding(.top, !contactModel.phoneNumber.isEmpty ? 0 : 15)
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
                }
            }
            VStack(spacing: 18) {
                NavigationLink  {
                        EditContactView(showTabBar: $showTabBar, showMenuContactOptions: $showMenuContactOptions, showMenuDelete: $showMenuDelete, fullName: contactModel.fullName, phoneNumber: contactModel.phoneNumber, email: contactModel.email, contactModel: contactModel)
                } label: {
                    Text("Edit")
                        .foregroundColor(.white)
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.size.height / 15.5)
                        .background(Color.customPrimary)
                        .cornerRadius(18)
                        .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                }
                Button {
                    showMenuContactOptions = false
                    showMenuDelete = true
                } label: {
                    Text("Delete")
                        .foregroundColor(.black)
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.size.height / 15.5)
                        .overlay(RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(lineWidth: 1.09)
                            .foregroundColor(.primarySubtle))
                        .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                }
            }
        }
        .padding(.top)
        .padding(.horizontal,16)
        .padding(.bottom,(UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30)
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .offset(y: max(offset.height, 0))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    print(gesture.translation)
                }
                .onEnded { gesture in
                        if offset.height > 80 {
                            showMenuContactOptions = false
                            showTabBar = true
                        } else {
                            withAnimation {
                                offset = .zero
                            }
                        }
                }
        )
    }
}
