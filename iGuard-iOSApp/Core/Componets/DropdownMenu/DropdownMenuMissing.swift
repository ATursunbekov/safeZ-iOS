import SwiftUI

struct DropdownMenuMissing: View {
    @Binding var showMenuMissing: Bool
    @Binding var showTabBar: Bool
    @State private var offset = CGSize.zero
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(spacing: 25) {
            VStack(alignment: .leading, spacing: 25) {
                Text("User is not in SafeZ forum")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 22))
                Text("This user is not using SafeZ yet and will receive SMS message in emergency  ")
                    .font(.custom(Gilroy.regular.rawValue, size: 16))
            }
            VStack(spacing: 18) {
                Button {
                    ShareHelper().share()
                    showMenuMissing = false
                    showTabBar = true
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Invite")
                        .foregroundColor(.white)
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.size.height / 15.5)
                        .background(Color.customPrimary)
                        .cornerRadius(18)
                        .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                }
                Button {
                    showMenuMissing = false
                    showTabBar = true
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
        .padding(.horizontal,16)
        .padding(.bottom,(UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30)
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .offset(y: max(offset.height, 0))
    }
    
}
