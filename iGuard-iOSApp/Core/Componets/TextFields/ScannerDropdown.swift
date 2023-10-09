//
//  ScannerDropdown.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 11/7/23.
//

import SwiftUI

struct ScannerDropdown: View {
    let placeholder: String
    @Binding var selectedObject: String
    var isState: Bool
    
    let drivingClassTypes: [String] = [ "AM",  "A2", "A", "B1", "B", "C1", "C", "D1", "D", "M", "L", "P", "BE", "C1E", "CE", "D1E", "DE", "T"]
    
    let stateNames = [
        "Alabama",
        "Alaska",
        "Arizona",
        "Arkansas",
        "California",
        "Colorado",
        "Connecticut",
        "Delaware",
        "Florida",
        "Georgia",
        "Hawaii",
        "Idaho",
        "Illinois",
        "Indiana",
        "Iowa",
        "Kansas",
        "Kentucky",
        "Louisiana",
        "Maine",
        "Maryland",
        "Massachusetts",
        "Michigan",
        "Minnesota",
        "Mississippi",
        "Missouri",
        "Montana",
        "Nebraska",
        "Nevada",
        "New Hampshire",
        "New Jersey",
        "New Mexico",
        "New York",
        "North Carolina",
        "North Dakota",
        "Ohio",
        "Oklahoma",
        "Oregon",
        "Pennsylvania",
        "Rhode Island",
        "South Carolina",
        "South Dakota",
        "Tennessee",
        "Texas",
        "Utah",
        "Vermont",
        "Virginia",
        "Washington",
        "West Virginia",
        "Wisconsin",
        "Wyoming"
    ]
    
    var body: some View {
        VStack {
            Group {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Menu {
                            ForEach(isState ? stateNames : drivingClassTypes, id: \.self){ client in
                                        Button(client) {
                                            self.selectedObject = client
                                        }
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading ,spacing: 4){
                                            Text(placeholder)
                                                .foregroundColor(.blackAlpha60)
                                                .font(.custom(Gilroy.regular.rawValue, size: 12))
                                            Text(selectedObject.isEmpty ? placeholder : selectedObject)
                                                .foregroundColor(selectedObject.isEmpty ? .gray : .black)
                                        }
                                        Spacer()
                                        Image(ProfileIcons.dropDownIcon.rawValue)
                                            .foregroundColor(Color.black)
                                            .frame(width: 24, height: 24)
                                    }
                                }
                        
                    }
                    .padding(.vertical, 8)
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
                    .foregroundColor(Color.backgroundForSearchBar.opacity(0.30))
            )
        }
        }
}
