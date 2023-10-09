//
//  ExtensionUIAplication.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 7/7/23.
//

import Foundation
import UIKit

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
