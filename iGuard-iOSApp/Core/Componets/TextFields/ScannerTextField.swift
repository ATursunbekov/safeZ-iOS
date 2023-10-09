//
//  ScannerTextField.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 11/7/23.
//

import SwiftUI

struct ScannerTextField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var showError: Bool
    let stateDictionary = [
        "AL": "Alabama",
        "AK": "Alaska",
        "AZ": "Arizona",
        "AR": "Arkansas",
        "CA": "California",
        "CO": "Colorado",
        "CT": "Connecticut",
        "DE": "Delaware",
        "FL": "Florida",
        "GA": "Georgia",
        "HI": "Hawaii",
        "ID": "Idaho",
        "IL": "Illinois",
        "IN": "Indiana",
        "IA": "Iowa",
        "KS": "Kansas",
        "KY": "Kentucky",
        "LA": "Louisiana",
        "ME": "Maine",
        "MD": "Maryland",
        "MA": "Massachusetts",
        "MI": "Michigan",
        "MN": "Minnesota",
        "MS": "Mississippi",
        "MO": "Missouri",
        "MT": "Montana",
        "NE": "Nebraska",
        "NV": "Nevada",
        "NH": "New Hampshire",
        "NJ": "New Jersey",
        "NM": "New Mexico",
        "NY": "New York",
        "NC": "North Carolina",
        "ND": "North Dakota",
        "OH": "Ohio",
        "OK": "Oklahoma",
        "OR": "Oregon",
        "PA": "Pennsylvania",
        "RI": "Rhode Island",
        "SC": "South Carolina",
        "SD": "South Dakota",
        "TN": "Tennessee",
        "TX": "Texas",
        "UT": "Utah",
        "VT": "Vermont",
        "VA": "Virginia",
        "WA": "Washington",
        "WV": "West Virginia",
        "WI": "Wisconsin",
        "WY": "Wyoming"
    ]
    
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
        }
}
