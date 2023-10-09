//
//  ExtensionKeyboard.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 27/6/23.
//

import SwiftUI

struct KeyboardDismissalModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
    }
}

extension View {
    func dismissKeyboardOnDrag() -> some View {
        self.modifier(KeyboardDismissalModifier())
    }
}
