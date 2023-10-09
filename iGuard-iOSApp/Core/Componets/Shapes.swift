//
//  Shapes.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 4/4/23.
//

import SwiftUI

struct ShapeCircle: Shape {
    let arcHeight: CGFloat
    let arcPosition: ArcPosition
    
    enum ArcPosition {
        case up
        case down
    }
    
    func path(in rect: CGRect) -> Path {
        var rectHeight = rect.height - arcHeight
        if rectHeight < 0 { rectHeight = 0 }
        var path = Path()
        switch arcPosition {
        case .up:
            path.move(to: CGPoint(x: rect.minX, y: arcHeight))
            path.addCurve(
                to: CGPoint(x: rect.maxX, y: arcHeight),
                control1: CGPoint(x: rect.midX, y: rect.minY),
                control2: CGPoint(x: rect.maxX, y: arcHeight)
            )
            path.addRect(CGRect(x: rect.minX, y: arcHeight, width: rect.width, height: rectHeight))
            
        case .down:
            path.move(to: CGPoint(x: rect.minX, y: rectHeight))
            path.addCurve(
                to: CGPoint(x: rect.maxX, y: rectHeight),
                control1: CGPoint(x: rect.midX, y: rect.maxY),
                control2: CGPoint(x: rect.maxX, y: rectHeight)
            )
            path.addRect(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rectHeight))
        }
        return path
    }
}
