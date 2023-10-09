import SwiftUI

extension Comparable
{
    func clamp<T: Comparable>(lower: T, _ upper: T) -> T {
        return min(max(self as! T, lower), upper)
    }
}

extension CGSize {
    static var inactiveThumbSizeHome: CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.height * 0.053)
    }
    
    static var activeThumbSizeHome: CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.height * 0.053)
    }
    
    static var trackSizeHome: CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.06)
    }
}


struct SwipeToUnlockHomeView: View {
    
    @State private var thumbSize: CGSize = CGSize.inactiveThumbSizeHome
    
    @State private var dragOffset: CGSize = .zero
    
    private let trackSize = CGSize.trackSizeHome
    
    @State private var isEnough = false
    
    private var actionSuccess: (() -> Void )?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black)
                .frame(width: trackSize.width, height: trackSize.height)
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white)
                    .frame(width: thumbSize.width, height: thumbSize.height)
                
                Image(HomeImage.swipeIcon.rawValue)
            }
            .offset(x: getDragOffsetX(), y: 0)
            .animation(Animation.spring(response: 0.3, dampingFraction: 0.8))
            .gesture(
                DragGesture()
                    .onChanged({ value in self.handleDragChanged(value)})
                    .onEnded({ value in handleDragChanged() })
            )
        }
    }
    private func getDragOffsetX() -> CGFloat {
        let clampeDragOffsetX = dragOffset.width.clamp(lower: 3.8, trackSize.width * 0.99 - thumbSize.width)
        return -(trackSize.width / 2 - thumbSize.width / 2 - (clampeDragOffsetX))
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) -> Void {
        self.dragOffset = value.translation
        let dragWidth = value.translation.width
        let targetDragWidth = self.trackSize.width - (self.thumbSize.width * 1)
        let wasInitiated = dragWidth > 2
        let didReachTarget = dragWidth > targetDragWidth
        
        self.thumbSize = wasInitiated ? CGSize.activeThumbSizeHome : CGSize.inactiveThumbSizeHome
        if didReachTarget {
            isEnough = true
        } else {
            self.isEnough = false
        }
    }
    private func handleDragChanged() -> Void {
        if isEnough {
            self.dragOffset = CGSize(width: self.trackSize.width - self.thumbSize.width, height: 0)
            if nil != self.actionSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.dragOffset = .zero
                    self.actionSuccess!()
                }
            }
        } else {
            self.dragOffset = .zero
        }
    }
}

extension SwipeToUnlockHomeView {
    func onSwipeSuccess(_ action: @escaping () -> Void ) -> Self {
        var this = self
        this.actionSuccess = action
        return this
    }
}
