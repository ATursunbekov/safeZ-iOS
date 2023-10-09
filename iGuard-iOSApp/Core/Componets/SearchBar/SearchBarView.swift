import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color.backgroundCircleSplash)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.backgroundForSearchBar.opacity(0.30), lineWidth: 1)
                )
            
            HStack(spacing: 13) {
                if searchText.isEmpty {
                    Image(ContactImage.search.rawValue)
                        .resizable()
                        .frame(width: 19, height: 19)
                }
                
                TextField("", text: $searchText)
                    .font(.custom(
                        Gilroy.regular.rawValue,
                        fixedSize: 16))
                    .placeholder(when: searchText.isEmpty) {
                        Text("Search")
                            .foregroundColor(.secondaryText)
                            .font(.custom(
                                Gilroy.regular.rawValue,
                                fixedSize: 16))
                }
                
                Spacer()
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(ContactImage.cancel.rawValue)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
    }
}
