//
//  ExtensionUIImage.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 5/5/23.
//

import SwiftUI
extension UIImage {
    func resize(to newSize: CGSize, scale: CGFloat = 0.5) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in draw(in: CGRect(origin: .zero, size: newSize))}
    }
}
