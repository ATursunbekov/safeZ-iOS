//
//  ExtensionShare.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 22/6/23.
//

import Foundation
import SwiftUI

class ShareHelper{
    
    func share() {
        let textToShare = """
        Hey,
        I'm using SafeZ for my personal safety companion, please use this link ‎https://apps.apple.com/us/app/safez/id6450197715 install the app so I can make you my emergency contact!
        """
        
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}
