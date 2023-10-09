//
//  DriverLicenseInfoView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 12/7/23.
//

import SwiftUI
import Kingfisher

struct DriverLicenseInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    let driverLicenseModel: DriverLicenseModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.black.ignoresSafeArea()
            ZStack(alignment: .topLeading) {
                if driverLicenseModel.state == "" {
                    // Image(DocumentsInfoImages.sample.rawValue)
                    Image(HomeImage.driverLicenseCard.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                else {
                    ZStack(alignment: .bottom) {
                        Image(HomeViewModel.lowercaseFirstLetterAndRemoveWhitespace(driverLicenseModel.state))
                            .resizable()
                            .frame(width: UIScreen.main.bounds.height * (800 / 896), height: UIScreen.main.bounds.width * (408 / 414))
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(15)
                            .blur(radius: 2)
                        Color.white
                            .frame(width: UIScreen.main.bounds.height * (800 / 896), height: UIScreen.main.bounds.width * (408 / 414))
                            .cornerRadius(15)
                            .opacity(0.3)
                        Color.white
                            .frame(width: UIScreen.main.bounds.height * (800 / 896), height: UIScreen.main.bounds.width * (350 / 414))
                            .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                            .opacity(0.2)
                    }
                }
                
                VStack(alignment: .leading ,spacing: DSize.fontSize(21)) {
                    Text("Driver license")
                        .font(.custom(Gilroy.medium.rawValue, size: DSize.fontSize(18)))
                        .padding(.bottom, (UIScreen.main.bounds.width * (20 / 414)))
                    
                    HStack(alignment: .bottom, spacing: 15.7) {
                        if driverLicenseModel.image != ""  {
                            if let image = driverLicenseModel.image {
                                KFImage(URL(string: image))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: DSize.getH(87), height: DSize.getH(87))
                                    .cornerRadius(DSize.getH(12))
                            }
                        } else {
                            RoundedRectangle(cornerRadius: DSize.getH(20))
                                .fill(.white)
                                .scaledToFit()
                                .cornerRadius(DSize.getH(12))
                                .frame(width: DSize.getH(87), height: DSize.getH(87))
                                .overlay (
                                    Image(ProfileIcons.profileAvatar.rawValue)
                                        .resizable()
                                        .frame(width: DSize.getH(52), height: DSize.getH(52))
                                )
                        }
                        VStack(alignment: .leading) {
                            HStack(spacing: 4) {
                                Image(DocumentsInfoImages.legalName.rawValue)
                                Text("Legal Name")
                                    .font(.custom(Gilroy.medium.rawValue, size: DSize.fontSize(12)))
                            }
                            Text(driverLicenseModel.name + " " + driverLicenseModel.lastName)
                                .font(.custom(Gilroy.semiBold.rawValue, size: DSize.fontSize(18)))
                        }
                        .padding(.bottom, 7)
                    }
                    
                    HStack(spacing: DSize.fontSize(33)) {
                        VStack(alignment: .leading, spacing: DSize.getSpace(10)) {
                            HStack(alignment: .bottom, spacing: DSize.fontSize(12.28)) {
                                HStack(alignment: .bottom, spacing: DSize.fontSize(4)) {
                                    Image(DocumentsInfoImages.dateOfBirth.rawValue)
                                    VStack {
                                        Text("Date of Birth")
                                            .font(.custom(Gilroy.medium.rawValue, size: DSize.fontSize(12)))
                                    }
                                }
                                Text(driverLicenseModel.dateOfBirth)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: DSize.fontSize(18)))
                                    .minimumScaleFactor(0.3)
                                    .lineLimit(1)
                                    .offset(y: 1)
                            }
                            HStack(alignment: .bottom, spacing: DSize.fontSize(12.28)) {
                                HStack(alignment: .bottom, spacing: DSize.fontSize(4)) {
                                    Image(DocumentsInfoImages.idNumber.rawValue)
                                    VStack {
                                        Text("ID Number")
                                            .font(.custom(Gilroy.medium.rawValue, size: DSize.fontSize(12)))
                                    }
                                }
                                Text(driverLicenseModel.documentID)
                                    .font(driverLicenseModel.documentID.count > 13 ? .custom(Gilroy.semiBold.rawValue, size: DSize.fontSize(10)) : .custom(Gilroy.semiBold.rawValue, size: DSize.fontSize(18)))
                                
                            }
                            HStack(alignment: .bottom, spacing: DSize.fontSize(12.28)) {
                                HStack(alignment: .bottom, spacing: DSize.fontSize(4)) {
                                    Image(DocumentsInfoImages.state.rawValue)
                                    VStack {
                                        Text("State")
                                            .font(.custom(Gilroy.medium.rawValue, size: DSize.fontSize(12)))
                                    }
                                }
                                Text(driverLicenseModel.state)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: DSize.fontSize(18)))
                                    .minimumScaleFactor(0.3)
                                    .lineLimit(1)
                                    .offset(y: 2)
                            }
                        }
                        VStack(alignment: .leading, spacing: DSize.getSpace(10)) {
                            HStack(alignment: .bottom, spacing: DSize.fontSize(12.28)) {
                                HStack(alignment: .center, spacing: DSize.fontSize(4)) {
                                    Image(DocumentsInfoImages.issueDate.rawValue)
                                    VStack {
                                        Text("Issue Date")
                                            .font(.custom(Gilroy.medium.rawValue, size: DSize.fontSize(12)))
                                    }
                                }
                                Text(driverLicenseModel.issueDate)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: DSize.fontSize(18)))
                                    .minimumScaleFactor(0.3)
                                    .lineLimit(1)
                                
                            }
                            HStack(alignment: .bottom, spacing: 12.28) {
                                HStack(alignment: .bottom, spacing: 4) {
                                    Image(DocumentsInfoImages.expirationDate.rawValue)
                                    VStack {
                                        Text("Expiration Date")
                                            .font(.custom(Gilroy.medium.rawValue, size: DSize.fontSize(12)))
                                    }
                                }
                                Text(driverLicenseModel.expirationDate)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: DSize.fontSize(18)))
                                    .minimumScaleFactor(0.3)
                                    .lineLimit(1)
                                
                            }
                            HStack(alignment: .bottom, spacing: DSize.fontSize(12.28)) {
                                HStack(alignment: .bottom, spacing: DSize.fontSize(4)) {
                                    Image(DocumentsInfoImages.drivingPrivileges.rawValue)
                                    VStack {
                                        Text("Driving Privileges")
                                            .font(.custom(Gilroy.medium.rawValue, size: DSize.fontSize(12)))
                                    }
                                }
                                Text(driverLicenseModel.drivingClass)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: DSize.fontSize(18)))
                                    .minimumScaleFactor(0.3)
                                    .lineLimit(1)
                                    .offset(y: 1)
                            }
                        }
                    }
                }
                .padding(15.34)
            }
        }
    }
}
