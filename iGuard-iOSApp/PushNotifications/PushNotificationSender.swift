//
//  PushNotificationSender.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 2/6/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class PushNotificationSender {
    
    static let shared = PushNotificationSender()
    
    private let urlString = "https://fcm.googleapis.com/fcm/send"
    
    private init() {}
    
    private func performRequest(url: URL, params: [String: Any]) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAAeQNk44:APA91bE_P0vmzRhJqHxO_yldR5nMN6T6G12XYbLsz8vdnjR3MaNPcExVUpG8zGNP5pmUNaZHvvRhZiVp9H0bkkegTzCrWxF8FUvodvcDMXm6USxkJXt-afdv4Ab_XBUslxhD5HmX0Vkf", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let jsonData = data {
                if let jsonDataDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    NSLog("Received data:\n\(jsonDataDict)")
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func sendStreamPushNotificationWithChannelName(to token: String, title: String, body: String, broadcasterID: String, time: String, streamType: Bool) {
        fetchChannelNameFirestore { [weak self]  channelName in
            guard let channelName = channelName else {
                return
            }
            guard let self = self else { return }
            
            let url = URL(string: self.urlString)!
            let params: [String: Any] = [
                "to": token,
                "notification": [
                    "title": title,
                    "body": body
                ],
                "data": [
                    "channelName": channelName,
                    "broadcasterUUID": broadcasterID,
                    "time": time,
                    "streamType": streamType
                ]
            ]
            self.performRequest(url: url, params: params)
        }
    }
    
    func sendMyLocationToContacts(to token: String, title: String, body: String, latitude: Double, longitude: Double) {
        let url = URL(string: urlString)!
        let params: [String: Any] = [
            "to": token,
            "notification" : [
                "title": title,
                "body": body
            ],
            "data": [
                "latitude": latitude,
                "longitude": longitude
            ]
        ]
        self.performRequest(url: url, params: params)
    }
    
    func sendContactRequestPushNotification(to token: String, title: String, body: String) {
        let url = URL(string: urlString)!
        let params: [String: Any] = [
            "to": token,
            "notification": [
                "title": title,
                "body": body
            ]
        ]
        performRequest(url: url, params: params)
    }
    
    private func fetchChannelNameFirestore(completion: @escaping (String?) -> Void) {
        var channelName: String?
        
        guard let currentUser = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        let collectionRef = Firestore.firestore().collection("contacts").document(currentUser).collection("items")
        
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Error receiving documents from contacts: \(error)")
                completion(nil)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("DEBUG: No documents found in contacts")
                completion(nil)
                return
            }
            
            for document in documents {
                if let channelNameValue = document.data()["channelName"] as? String
                {
                    channelName = channelNameValue 
                    print("RichedThisPlace!!!")
                }
            }
            completion(channelName)
        }
    }
    
}
