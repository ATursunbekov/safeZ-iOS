//
//  EntitlementManager.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 31/7/23.
//

import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "app.iguard.subscriptions")!
    
    @AppStorage("hasPro", store: userDefaults)
    
    var hasPro: Bool = false
}
