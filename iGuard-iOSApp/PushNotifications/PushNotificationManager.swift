//
//  PushNotificationManager.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 28/5/23.
//
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications
import SwiftUI

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }
    
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection("users").document(userID)
            usersRef.setData(["fcmToken": token], merge: true)
            print("FCM TOKEN: \(token)")
        }
    }
    
    static func removeFcmTokenFirestore(forUserUid userUid: String) {
        let userRef = Firestore.firestore().collection("users").document(userUid)
        
        userRef.updateData(["fcmToken": FieldValue.delete()]) { error in
            if let error = error {
                print("Error removing FCM token: \(error.localizedDescription)")
                return
            }
        
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let channelNameValue = userInfo["channelName"] as? String {
            AgoraViewerHelper.agview.viewer.leaveChannel()
            NavigationManager.shared.isOpenLiveStream = false
            NavigationManager.shared.broadcasterStreamOn = false
            NavigationManager.shared.channelName = channelNameValue
            NavigationManager.shared.broadcasterData = BroadcasterData(channelName: channelNameValue, broadcasterID: userInfo["broadcasterUUID"] as? String ?? "QuspxSC2mzUyZRMP9BOmQ7Aqosj2", time: userInfo["time"] as? String ?? "2023-06-15 10:30:00")
            if let streamType = userInfo["streamType"] as? String {
                NavigationManager.shared.isHiddenStream = streamType == "true" ? true : false
                print("Received Boolean: \(NavigationManager.shared.isHiddenStream)")
            } else {
                print("Unable to extract streamType as Bool from userInfo. \(userInfo["streamType"])")
            }
            print("CLICK")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NavigationManager.shared.selectedTab = .home
                NavigationManager.shared.isOpenLiveStream = true
            }
        } else {
            print("Something is wrong there")
        }
                        
        if let longitude = userInfo["longitude"] as? String, let latitude = userInfo["latitude"] as? String {
            print(longitude)
            NavigationManager.shared.isOpenMapView = true
            NavigationManager.shared.latitude = Double(latitude) ?? 0.0
            NavigationManager.shared.longitude = Double(longitude) ?? 0.0
        } else {
            print("nil")
        }
        NavigationManager.shared.selectedTab = .home
        NavigationManager.shared.isOpenNotificationView = true
        completionHandler()
    }
}
