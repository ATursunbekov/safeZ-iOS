
import SwiftUI

struct SplashScreen: View {
    
    @State private var progressValue: Float = 0.0
    @State private var isActive = false
    @State private var isLoading = true
    
    var body: some View {
        if isActive {
                SignInView()
        } else {
            ZStack() {
                background
                VStack() {
                    Image(SplashImage.logoForSplash.rawValue)
                        .padding(.bottom, 0)
                    VStack(spacing: 100) {
                        Text("SafeZ")
                            .font(.custom(Gilroy.semiBold.rawValue, size: 48))
                            .padding(.top, 30)
                        if isLoading {
                            ProgressBar(progress: self.$progressValue)
                                .frame(width: 48, height: 48)
                                .onAppear {
                                    self.progressValue = 1.0
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        self.isActive = true
                                    }
                                }
                        }
                    }
                }
                .padding(.top, 116)
            }
        }
    }
    private var background: some View {
        GeometryReader { proxy in
            let mult = proxy.safeAreaInsets.bottom == 0 ? 0.9 : 1
            let size = proxy.size.width * 2 * mult
            ZStack() {
                Circle()
                    .fill(
                        Color.backgroundCircleSplash
                    )
                    .frame(width: size, height: size)
                    .offset(
                        x: proxy.frame(in: .local).midX - size / 2,
                        y: proxy.frame(in: .local).midY)
            }
        }
    }
}

struct ProgressBar: View {
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8.0)
                .fill(Color.backgroundForLoader)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                .fill(Color.primarySubtle)
                .rotationEffect(Angle(degrees: 360 * Double(self.progress)))
                .animation(Animation.linear(duration: 2), value: UUID())
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
