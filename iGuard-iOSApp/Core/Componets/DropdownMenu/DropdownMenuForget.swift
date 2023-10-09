
import SwiftUI

struct DropdownMenuForget: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var show: Bool
    @Binding var messageText: String
    @State private var offset = CGSize.zero
    @Binding var hideCancelButton: Bool
    
    var body: some View {
        VStack(spacing: 25) {
            Capsule()
                .fill(Color.colorDate)
                .frame(width: 40, height: 2)
            Text("Please check your email")
                .font(.custom(Gilroy.semiBold.rawValue, size: 22))
            Circle()
                .fill(Color.backgroundCircleSplash)
                .frame(width: 157, height: 157)
                .overlay (
                    Image(HomeImage.message.rawValue)
                )
            Text("Password reset link has been sent to the email : \(messageText)")
                .accentColor(.secondaryText)
                .foregroundColor(.secondaryText)
                .font(.custom(Gilroy.regular.rawValue, size: 18))
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Text("OK")
                    .foregroundColor(.white)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.size.height / 15.5)
                    .background(Color.customPrimary)
                    .cornerRadius(18)
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
                        if offset.height > 220 {
                            show = false
                            hideCancelButton = true
                            offset = .zero
                        } else {
                            withAnimation {
                                offset = .zero
                            }
                        }
                }
        )
    }
    
}
