
import SwiftUI

struct DropdownMenuExist: View {
    @Binding var showMenuExist: Bool
    @Binding var showTabBar: Bool
    @State private var offset = CGSize.zero
    @Environment(\.presentationMode) private var presentationMode
    
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 25) {
            Capsule()
                .fill(Color.colorDate)
                .frame(width: 40, height: 2)
            VStack(alignment: .leading, spacing: 25) {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 22))
                Text(description)
            }
            .font(.custom(Gilroy.regular.rawValue, size: 16))
            Button {
                showMenuExist = false
                showTabBar.toggle()
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("OK")
                    .foregroundColor(.white)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.size.height / 15.5)
                    .background(Color.customPrimary)
                    .cornerRadius(18)
                    .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
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
                            showMenuExist = false
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

