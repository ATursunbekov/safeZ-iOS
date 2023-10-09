//
//  ExtensionSize.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 15/9/23.
//

import Foundation
import UIKit

class DSize {
    static func getH(_ height: Double) -> Double {
        return (UIScreen.main.bounds.height * height / 896)
    }
    
    static func getW(_ width: Double) -> Double {
        return (UIScreen.main.bounds.width * width / 414)
    }
    
    // For ipad paddings
    static func isIpad() -> Double {
        return UIDevice.isIPhone ? 0 : getH(20)
    }
    
    // For font size
    static func fontSize(_ size: Double) -> Double {
        if UIDevice.isIPad {
            return getW(size)
        } else {
            return getH(size * 1.5)
        }
    }
    
    //For space in Card for iPad
    static func getSpace(_ size: Double) -> Double {
        if UIDevice.isIPad {
            return getW(size * 3)
        } else {
            return getH(size)
        }
    }
    
}

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
