
import SwiftUI

struct SettingsView: View {
    @Environment (\.presentationMode) private var presentationMode
    @State private var autoAlertIsOn = false
    @State private var notifyIsOn = false
    @State private var notifySecondIsOn = false
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                background
                VStack(spacing: 12) {
                    autoAlert
                    notify
                }
             .padding(.top, 80)
            }.padding(.horizontal, 13)
            Spacer()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(ProfileIcons.arrowBack.rawValue)
                        .imageScale(.large)
                        .frame(width: 35, height: 30, alignment: .leading)
                }
                .frame(width: 35, height: 30, alignment: .leading)
            }
        }
        .padding(.top, 14)
    }
    
    private var autoAlert: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(height: 85)
            Toggle(isOn: $autoAlertIsOn) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Auto alert")
                            .font(.custom(Gilroy.bold.rawValue, size: 16))
                        Text("Automatically trigger the recording \nwhen the identification is accessed")
                            .foregroundColor(.black.opacity(0.5))
                            .font(.custom(Gilroy.regular.rawValue, size: 14))
                    }
                    Spacer()
                    Text(autoAlertIsOn ? "ON" : "OFF")
                        .font(.custom(Gilroy.semiBold.rawValue, size: 14))
                        .padding(.top, 4)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .customPrimary))
            .padding(.horizontal)
        }
    }
    private var notify: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(height: 85)
            Toggle(isOn: $notifyIsOn) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notify my contacts")
                            .font(.custom(Gilroy.bold.rawValue, size: 16))
                        Text("Send notifications to all contacts")
                            .font(.custom(Gilroy.regular.rawValue, size: 14))
                            .foregroundColor(.black.opacity(0.5))
                    }
                    Spacer()
                    Text(notifyIsOn ? "ON" : "OFF")
                        .font(.custom(Gilroy.semiBold.rawValue, size: 14))
                        .padding(.top, 4)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .customPrimary))
            .padding(.horizontal)
        }
    }
    private var background: some View {
        GeometryReader { proxy in
            let mult = proxy.safeAreaInsets.bottom == 0 ? 0.9 : 1
            let size = proxy.size.width * 2.5 * mult
            ZStack() {
                Circle()
                    .fill(
                        Color.backgroundCircleSplash
                    )
                    .frame(width: size, height: size)
                    .offset(
                        x: proxy.frame(in: .local).midX - size / 2,
                        y: proxy.frame(in: .local).midY * 0.04)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
