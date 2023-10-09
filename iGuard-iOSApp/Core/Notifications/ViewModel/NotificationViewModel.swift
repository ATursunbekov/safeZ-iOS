//
//  NotificationViewModel.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 17/4/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class NotificationViewModel: ObservableObject {
    @Published var notificationArray = [NotificationModel]()
    @Published var selectedNotification: NotificationModel?
    @Published var channelName = ""
    @Published var isOpenLiveStream = false
    var listener: ListenerRegistration?
    
    
    init() {
        getNotifications()
    }
    
    func acceptRequest(notificationModel: NotificationModel) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let contactModel = ContactModel(id: notificationModel.id, fullName: notificationModel.fullName, phoneNumber: "", email: notificationModel.senderEmail, status: "")
        
        guard let encodedUser = try? Firestore.Encoder().encode(contactModel) else { return }
        
        Firestore.firestore().collection("contacts").document(currentUser.uid).collection("items").document(notificationModel.id).setData(encodedUser) { error in
            if let error = error {
                print("Failed to setData: \(error)")
            }
        }
        Firestore.firestore().collection("contacts").document(notificationModel.id).collection("items").document(currentUser.uid).updateData(["status": "accepted"])
        
        Firestore.firestore().collection("notifications").document(currentUser.uid).collection("items").document(notificationModel.id)
            .updateData(["status": "accepted",
                         "requestMessage": "You added a contact"]) { error in
                if let error = error {
                    print("Failed to update request message: \(error.localizedDescription)")
                }
            }
        getDataFromContact(notificationModel: notificationModel, requestMessage: "accepted your add request", status: "accept")
    }
    
    func rejectRequest(notificationModel: NotificationModel) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Firestore.firestore().collection("contacts").document(notificationModel.id).collection("items").document(currentUser.uid).delete() { error in
                if let error = error {
                    print("Failed to reject the contact request: \(error.localizedDescription)")
                }
            }
        }
        
        Firestore.firestore().collection("notifications").document(currentUser.uid).collection("items").document(notificationModel.id).delete { error in
            if let error = error {
                print("Failed to delete notification: \(error.localizedDescription)")
            } else {
                print("Notification deleted successfully")
            }
        }
        getDataFromContact(notificationModel: notificationModel, requestMessage: "rejected your add request", status: "reject")
    }
    
    private func sendNotification(notificationModel: NotificationModel, requestMessage: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Firestore.firestore().collection("users").document(notificationModel.id).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching another user data: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot, document.exists, let dataAnotherUser = document.data() else {
                print("Another user document does not exist or has no data")
                return
            }
            
            Firestore.firestore().collection("users").document(currentUser.uid).getDocument { snapshot, _ in
                guard let document = snapshot, document.exists, let data = document.data() else {
                    print("Current user document does not exist or has no data")
                    return
                }
                
                let fullName = data["fullName"] as? String
                let fcmToken = dataAnotherUser["fcmToken"] as? String
                let body = "\(requestMessage) your add request"
                PushNotificationSender.shared.sendContactRequestPushNotification(to: fcmToken ?? "", title: fullName ?? "", body: body)
            }
        }
    }
    
    func sendAcceptedNotification(notificationModel: NotificationModel) {
        sendNotification(notificationModel: notificationModel, requestMessage: "accepted")
    }
    
    func sendRejectedNotification(notificationModel: NotificationModel) {
        sendNotification(notificationModel: notificationModel, requestMessage: "rejected")
    }
    
    func deleteItem(_ notificationModel: NotificationModel) {
        guard let currentUser = Auth.auth().currentUser else { return }
        Firestore.firestore().collection("notifications").document(currentUser.uid).collection("items").document(notificationModel.id).delete() { error in
            if let error = error {
                print("Error deleting notification: \(error)")
            } else {
                print("Notification successfully deleted")
            }
        }
    }
    
    private func getDataFromContact(notificationModel: NotificationModel, requestMessage: String, status: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        Firestore.firestore().collection("contacts").document(notificationModel.id).collection("items").document(currentUser.uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to get document: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot, document.exists else {
                print("Document does not exist")
                return
            }
            
            let data = document.data()
            if let fullName = data?["fullName"] as? String {
                let email = data?["email"] as? String
                let id = data?["id"] as? String
                let notificationModelInContact = NotificationModel(id: id ?? "", fullName: fullName, requestMessage: requestMessage, senderEmail: email ?? "", status: status, statusStream: nil)
                guard let encodedUser = try? Firestore.Encoder().encode(notificationModelInContact) else { return }
                let ref = Firestore.firestore().collection("notifications").document(notificationModel.id).collection("items").document(currentUser.uid)
                ref.setData(encodedUser)
                ref.updateData(["date" : FieldValue.serverTimestamp()])
            }
        }
    }
    
    func updateIsUnread() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let collectionRef = Firestore.firestore().collection("notifications").document(currentUserID).collection("items")
        
        listener =  collectionRef.whereField("isUnread", isEqualTo: true).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Failed to fetch documents with isUnread = true: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found with isUnread = true")
                return
            }
            
            for document in documents {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    collectionRef.document(document.documentID).updateData(["isUnread": false]) { error in
                        if let error = error {
                            print("Failed to update read state in Firestore for document \(document.documentID): \(error.localizedDescription)")
                        } else {
                            print("Read state updated successfully in Firestore for document \(document.documentID)")
                        }
                    }
                }
            }
        }
    }
    
    func updatePhotoNotifications(notificationModel: NotificationModel) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Firestore.firestore().collection("contacts").document(currentUser.uid).collection("items").getDocuments { userSnapshot, error in
            
            if let error = error {
                print("Failed fetching user: \(error.localizedDescription)")
                return
            }
            
            guard let userDocuments = userSnapshot?.documents else {
                print("User document does not exist")
                return
            }
            
            for document in userDocuments {
                if let userId = document.data()["id"] as? String {
                    let usersAddSnapshotListener = Firestore.firestore().collection("users").document(userId)
                    
                    usersAddSnapshotListener.addSnapshotListener { userSnapshot, error in
                        
                        guard let userDocument = userSnapshot else {
                            print("User document does not exist")
                            return
                            
                        }
                        let ref = Firestore.firestore().collection("notifications").document(currentUser.uid).collection("items").whereField("id", isEqualTo: userId)
                        
                        if let avatar = userDocument.data()?["avatar"] as? String, let fullName = userDocument.data()?["fullName"] {

                            ref.getDocuments { userSnapshot, _ in
                                
                                guard let userDocuments = userSnapshot?.documents else {
                                    print("User document does not exist")
                                    return
                                    
                                }
                                
                                for document in userDocuments {
                                    document.reference.updateData(["imageURL" : avatar,
                                                                   "fullName" : fullName
                                                                  ])
                                }
                            }
                        } else {
                            
                            if let fullName = userDocument.data()?["fullName"] {
                                ref.getDocuments { userSnapshot, _ in
                                    
                                    guard let userDocuments = userSnapshot?.documents else {
                                        print("User document does not exist")
                                        return
                                        
                                    }
                                    
                                    for document in userDocuments {
                                        document.reference.updateData(["imageURL" : FieldValue.delete(),
                                                                       "fullName" : fullName])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

        func getNotifications() {
            guard let currentUser = Auth.auth().currentUser else { return }
            Firestore.firestore().collection("notifications").document(currentUser.uid).collection("items").order(by: "date", descending: true).addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Failed to get notification documents: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("Notification documents snapshot is nil")
                    return
                }
                
                self?.notificationArray = documents.compactMap { document in
                    var notification = try? document.data(as: NotificationModel.self)
                    notification?.id = document.documentID
                    return notification
                }
            }
        }
        
        func handleNotificationSelection(notification: NotificationModel) {
            guard let currentUser = Auth.auth().currentUser else {
                print("Current user not available")
                return
            }
            
            if notification.requestMessage != "Started Live" {
                return
            }
            
            selectedNotification = notification
            
            let notificationRef = Firestore.firestore().collection("notifications").document(currentUser.uid).collection("items").document(notification.id)
            
            notificationRef.getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("Failed to fetch notification document: \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshot, document.exists else {
                    print("Notification document does not exist")
                    return
                }
                
                guard let userUid = document.data()?["id"] as? String else {
                    print("User UID not found in notification document")
                    return
                }
                
                let contactRef = Firestore.firestore().collection("contacts").document(userUid).collection("items").document(currentUser.uid)
                
                contactRef.getDocument { [weak self] snapshot, error in
                    if let error = error {
                        print("Failed to fetch contact document: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let document = snapshot, document.exists else {
                        print("Contact document does not exist")
                        return
                    }
                    
                    let data = document.data()
                    
                    if notification.statusStream == "start", let channelName = data?["channelName"] as? String {
                        self?.isOpenLiveStream = true
                        self?.channelName = channelName
                        print("DEBUG: CHANNEL NAME --\(channelName)")
                    } else if notification.statusStream == "stop" {
                        self?.isOpenLiveStream = false
                        print("STOP STATUS")
                    }
                }
            }
        }
    }
