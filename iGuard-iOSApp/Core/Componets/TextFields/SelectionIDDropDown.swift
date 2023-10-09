import SwiftUI

struct SelectionIDDropDown: View {
    let placeholder: String
    @Binding var selectedObject: String
    let idTypes: [String] = ["Driver license","ID"]
    
    var body: some View {
        VStack {
            Group {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Menu {
                            ForEach(idTypes, id: \.self){ client in
                                        Button(client) {
                                            self.selectedObject = client
                                        }
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading ,spacing: 10){
                                            Text(placeholder)
                                                .font(.custom(Gilroy.medium.rawValue, size: 14))
                                                .foregroundColor(.secondaryText)
                                            Text(selectedObject.isEmpty ? placeholder : selectedObject)
                                                .font(.custom(Gilroy.semiBold.rawValue, size: 16))
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
            .frame(height: 74)
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
