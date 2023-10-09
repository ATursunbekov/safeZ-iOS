//
//  ScannerDateTextField.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 11/7/23.
//

import SwiftUI

struct ScannerDateTextField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var showError: Bool
    @State var tempText = ""
    
    var body: some View {
        VStack {
            Group {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        if !text.isEmpty {
                            Text(placeholder)
                                .foregroundColor(.blackAlpha60)
                                .font(.custom(Gilroy.regular.rawValue, size: 12))
                            Spacer()
                                .frame(height: 4)
                        }
                        TextField(placeholder, text: $text)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .onChange(of: text) { newValue in
                                if tempText < text {
                                    if text.count == 2 {
                                        text += "/"
                                    } else if text.count == 5 {
                                        text += "/"
                                    }
                                } else if tempText > text{
                                    if text != "" && !text.last!.isNumber {
                                        text = String(text.dropLast(1))
                                    }
                                }
                                if text.count > 10 {
                                    let index = text.index(text.startIndex, offsetBy: 10)
                                    text = String(text[..<index])
                                }
                                tempText = text
                            }
                    }
                    .padding(.vertical, 8)
                    Spacer()
                    if showError {
                        Button {
                            text = ""
                        } label: {
                            Image(HomeImage.iconoirCancel.rawValue)
                                .frame(width: 24, height: 24)
                        }
                    } else {
                        Button {} label: {
                            Image(DocumentsImage.editScannedData.rawValue)
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
            .autocapitalization(.none)
            .autocorrectionDisabled(true)
            .foregroundColor(.black)
            .frame(height: 54)
            .padding(.horizontal, 18)
            .background(Color.white)
            .font(.custom(Gilroy.regular.rawValue, size: 16))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(lineWidth: 1)
                    .foregroundColor(showError ? Color.red : Color.backgroundForSearchBar.opacity(0.30))
            )
            if showError {
                Text("Not a valid information. Please check/reenter")
                    .foregroundColor(.red)
                    .font(.custom(Gilroy.regular.rawValue, size: 12))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 19)
            }
        }
        .onChange(of: text) { newValue in
            showError = false
        }
        .onAppear {
            getDate()
        }
        }
    
    func getDate() {
        let inputDateString = text

        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "MMddyyyy"

        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "MM/dd/yyyy"

        if let date = inputDateFormatter.date(from: inputDateString) {
            let outputDateString = outputDateFormatter.string(from: date)
            text = outputDateString
        }
    }
}
