//
//  iGuard_iOSAppApp.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 17/3/23.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import FirebaseAuth
import FirebaseFirestore
@main
struct iGuard_iOSAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var entitlementManager: EntitlementManager
    @StateObject private var purchaseManager: PurchaseManager

    init() {
        let entitlementManager = EntitlementManager()
        let purchaseManager = PurchaseManager(entitlementManager: entitlementManager)
        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._purchaseManager = StateObject(wrappedValue: purchaseManager)
    }
    
    var body: some Scene {
        WindowGroup {
                SplashScreen()
                .environmentObject(entitlementManager)
                .environmentObject(purchaseManager)
                .environmentObject(authViewModel)
                .environmentObject(homeViewModel)
                .task {
                    await purchaseManager.updatePurchasedProducts()
                }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    let userDefaults = UserDefaults.standard
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        if let expirationDate = UserDefaults.standard.object(forKey: "trialExpirationDate") as? Date {
            if Date() >= expirationDate {
                UserDefaults.standard.set(false, forKey: "isTrialActive")
            }
        }
        
        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
            userDefaults.setValue(true, forKey: "appFirstTimeOpend")
            do {
                try Auth.auth().signOut()
            }catch {

            }
        }
        if let currentUser = Auth.auth().currentUser {
            let pushNotifications = PushNotificationManager(userID: currentUser.uid)
             pushNotifications.registerForPushNotifications()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
}
