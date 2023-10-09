//
//  SubscriptionDataManager.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 13/7/23.
//

import FirebaseFirestore
import FirebaseAuth

class SubscriptionDataManager {
    private let firestore = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser?.uid
    
    func saveSubscriptionStatus(isSubscribed: Bool, startDate: Date?, endDate: Date?, subscriptionType: String?) {
        guard let userId = currentUser else {
            print("No user ID available.")
            return
        }
        
        var data: [String: Any] = [
            "isSubscribed": isSubscribed
        ]
        
        if let startDate = startDate {
            data["startDate"] = startDate
        }
        
        if let endDate = endDate {
            data["endDate"] = endDate
        }
        
        if let subscriptionType = subscriptionType {
            data["subscriptionType"] = subscriptionType
        }
        
        let documentReference = firestore.collection("subscriptions").document(userId)
        
        documentReference.setData(data, merge: true) { error in
            if let error = error {
                print("Error saving subscription status: \(error.localizedDescription)")
            } else {
                print("Subscription status saved successfully.")
            }
        }
    }
    
    func fetchSubscriptionStatus(completion: @escaping (Bool, Date?, Date?, String?) -> Void) {
        guard let userId = currentUser else {
            print("No user ID available.")
            completion(false, nil, nil, nil)
            return
        }
        
        let documentReference = firestore.collection("subscriptions").document(userId)
        
        documentReference.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching subscription status: \(error.localizedDescription)")
                completion(false, nil, nil, nil)
                return
            }
            
            if let snapshot = snapshot, let data = snapshot.data() {
                let isSubscribed = data["isSubscribed"] as? Bool ?? false
                let startDate = data["startDate"] as? Date
                let endDate = data["endDate"] as? Date
                let subscriptionType = data["subscriptionType"] as? String
                
                completion(isSubscribed, startDate, endDate, subscriptionType)
            } else {
                completion(false, nil, nil, nil)
            }
        }
    }
}
