//
//  DropDownMenuDeleteRecording.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 24/6/23.

import SwiftUI

struct DropDownMenuDeleteRecording: View {
    @EnvironmentObject var viewModel: RecordingViewModel
    @Binding var showMenuDelete: Bool
    @Binding var showTabBar: Bool
    @Environment(\.presentationMode) var presentationMode
    let selectedVideo: RecordingFetchedData
    
    var body: some View {
        VStack(spacing: 38) {
            VStack(alignment: .leading, spacing: 25) {
                Text("Delete video")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 22))
                Text("Are you sure you want to delete video: \(getCurrentDate(recDate:selectedVideo.date)), \(selectedVideo.size) Mb?")
                    .font(.custom(Gilroy.regular.rawValue, size: 16))
                    .frame(maxHeight: 35)
            }
            VStack(spacing: 18) {
                Button {
                    showMenuDelete = false
                    withAnimation() {
                        viewModel.deleteRecording(video: selectedVideo)
                    }
                } label: {
                    Text("Yes")
                        .foregroundColor(.white)
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.size.height / 15.5)
                        .background(Color.customPrimary)
                        .cornerRadius(18)
                        .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                }
                Button {
                        showMenuDelete = false
                } label: {
                    Text("Cancel")
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
        .padding(.top, 30)
        .padding(.horizontal,22)
        .padding(.bottom,(UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30)
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.12), radius: 2, x: -2)
    }
    
    func getCurrentDate(recDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: recDate)
        return dateString
    }
}
