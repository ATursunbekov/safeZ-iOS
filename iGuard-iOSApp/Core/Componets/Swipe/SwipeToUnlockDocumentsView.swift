//
//  SwipeToUnlockDocumentsView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 17/7/23.
//

import SwiftUI

import SwiftUI

let width = UIScreen.main.bounds.width
let height = UIScreen.main.bounds.height

extension CGSize {
    static var inactiveThumbSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.40, height: UIScreen.main.bounds.height * 0.053)
    }
    
    static var activeThumbSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.40, height: UIScreen.main.bounds.height * 0.053)
    }
    
    static var trackSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.06)
    }
}

struct SwipeToUnlockDocumentsView: View {
    
    @State private var thumbSize: CGSize = CGSize.inactiveThumbSize
    
    @State private var dragOffset: CGSize = .zero
    
    let text: String?
    
    let image: String
    
    private let trackSize = CGSize.trackSize
    
    @State private var isEnough = false
    
    private var actionSuccess: (() -> Void )?
    
    init(text: String, image: String) {
        self.text = text
        self.image = image
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black)
                .frame(width: trackSize.width, height: trackSize.height)
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white)
                    .frame(width: thumbSize.width, height: thumbSize.height)
                
                HStack {
                    Image(image)
                    Text(text ?? "")
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                }
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
        
        self.thumbSize = wasInitiated ? CGSize.activeThumbSize : CGSize.inactiveThumbSize
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

extension SwipeToUnlockDocumentsView {
    func onSwipeSuccess(_ action: @escaping () -> Void ) -> Self {
        var this = self
        this.actionSuccess = action
        return this
    }
}
