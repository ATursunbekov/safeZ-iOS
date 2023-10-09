//
//  ContactsModelView.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 16/4/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseDatabase
import SwiftUI
import AVFoundation

enum ContactRequestError: Error {
    case contactAdded(title: String, description: String)
    case addingSelf(title: String, description: String)
    case limitReached(title: String, description: String)
    case alreadySent(title: String, description: String)
}

class ContactsViewModel: ObservableObject {
    @ObservedObject private var entitlementManager = EntitlementManager()
    let storeKitViewModel = StoreKitViewModel()
    let subscriptionDataManager = SubscriptionDataManager()
    let isTrialActive = UserDefaults.standard.bool(forKey: "isTrialActive")
    @Published var contacts = [ContactModel]()
    @Published var getEndStatus = true
    @Published public var getStartStatus = true
    @Published public var showLimitExceededAlert = false
    
    private let db = Firestore.firestore()
    //MARK: vars for live stream
    var token: TokenModel?
    var listener: ListenerRegistration?
    
    // Vars for getting name and avatar of broadcaster
    @Published var fullName: String?
    @Published var avatarString: String? = ""
    @Published var avatarUser: URL?
    init() {
        getContacts()
    }
  
    func fetchBroadcasterData() {
        //guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        guard let currentUserUid = NavigationManager.shared.broadcasterData?.broadcasterID else { return }
        db.collection("users").document(currentUserUid).addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot else {
                print("Error fetching document: \(String(describing: error))")
                return
            }
            guard let fullName = document.data()?["fullName"] as? String else {
                print("Document data was empty.")
                return
            }
            self.fullName = fullName
            guard let avatarUser = document.data()?["avatar"] as? String  else {
                self.avatarString = nil
                return
            }
            self.avatarUser = URL(string: avatarUser)
        }
    }
  
    func sendContactRequest(fullName: String, phoneNumber: String, email: String, completion: @escaping (Bool, ContactRequestError?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        subscriptionDataManager.fetchSubscriptionStatus { [weak self] isSubscribed, _, _, _ in
            guard let self = self else { return }
            
            if !entitlementManager.hasPro || !isTrialActive {
                if self.contacts.count >= 3 {
                    showLimitExceededAlert = true
                    
                    return
                }
            }
            
            getUserUID(email: email) { [weak self] uid in
                guard let uid = uid else {
                    completion(false, nil)
                    return
                }
                
                self?.db.collection("contacts").document(currentUser.uid).collection("items").whereField("email", isEqualTo: email).getDocuments { snapshot, _ in
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        if currentUser.email == email {
                            completion(false, .addingSelf(title: "You can't add yourself", description: "You can't add yourself as a contact. Please select a different contact to add."))
                            return
                        }
                        
                        guard let self = self else { return }
                        
                        let user = ContactModel(id: uid, fullName: fullName, phoneNumber: phoneNumber, email: email, status: "pending")
                        guard let encodedUser = try? Firestore.Encoder().encode(user) else {
                            completion(false, nil)
                            return
                        }
                        self.db.collection("contacts").document(currentUser.uid).collection("items").document(uid).setData(encodedUser)
                        self.db.collection("users").document(currentUser.uid).getDocument { snapshot, _ in
                            if let document = snapshot, document.exists {
                                guard let data = document.data() else { return }
                                let fullName = data["fullName"] as? String
                                let imageURL = data["avatar"] as? String
                                let emailUser = data["email"] as? String
                                self.sendNotifications(getUid: uid, uid: currentUser.uid, fullName: fullName ?? "", imageURL: imageURL, senderEmail: emailUser ?? "")
                                self.sendPushNotifications(email: email)
                                completion(true, nil)
                            } else {
                                completion(false, nil)
                            }
                        }
                        return
                    }
                    for document in documents {
                        if let status = document.data()["status"] as? String, status == "pending" {
                            completion(false, .alreadySent(title: "Contact request already sent", description: "You have already sent a contact request to this user. Please wait for their response or consider contacting someone else."))
                            return
                    }
                }
                    completion(false, .contactAdded(title: "The contact is already added.", description: "Please note that the contact you are trying to add is already in your contacts list."))
                }
            }
        }
    }

    func updatePhotoContacts(contactModel: ContactModel) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Firestore.firestore().collection("users").document(contactModel.id).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Failed fetching users: \(error.localizedDescription)")
            }
            guard let document = snapshot, document.exists else {
                print("Document does not exist")
                return
            }
            if let avatar = document.data()?["avatar"] as? String {
                Firestore.firestore().collection("contacts").document(currentUser.uid).collection("items").document(contactModel.id).updateData(["image": avatar])
            } else {
                Firestore.firestore().collection("contacts").document(currentUser.uid).collection("items").document(contactModel.id).updateData(["image": FieldValue.delete()])
            }
        }
    }
    
    func sendPushNotifications(email: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        getUserUID(email: email) { [weak self] uid in
            guard let uid = uid else { return }
            guard let self = self else  { return }
            self.db.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching another user data: \(error.localizedDescription)")
                    return
                }
                guard let document = snapshot, document.exists, let dataAnotherUser = document.data() else {
                    print("Another user document does not exist or has no data")
                    return
                }
                self.db.collection("users").document(currentUser.uid).getDocument { snapshot, _ in
                    guard let document = snapshot, document.exists, let data = document.data() else {
                        print("Current user document does not exist or has no data")
                        return
                    }
                    let fullName = data["fullName"] as? String
                    let fcmToken = dataAnotherUser["fcmToken"] as? String
                    PushNotificationSender.shared.sendContactRequestPushNotification(to: fcmToken ?? "", title: fullName ?? "", body: "Wants to add you to contacts")
                }
            }
        }
    }
    
    
    
    private func getContacts() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let query = db.collection("contacts").document(currentUser.uid).collection("items").whereField("status", in: ["accepted", ""])
        
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }
            self.contacts = documents.compactMap { try? $0.data(as: ContactModel.self) }
            self.sortContactsAlphabetically()
        }
    }   
    
    func sortContactsAlphabetically() {
        contacts.sort { $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending }
    }
    
    private func getUserUID(email: String?, completion: @escaping (String?) -> Void) {
        db.collection("users").whereField("email", isEqualTo: email ?? "").getDocuments { (snapshot, error) in
            if let error = error {
                print("Failed to get user UID: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let snapshot = snapshot, let document = snapshot.documents.first else {
                print("The user with the specified email is not found")
                completion(nil)
                return
            }
            
            let uid = document.documentID
            completion(uid)
        }
    }
    
    func editContact(fullName: String, phoneNumber: String, email: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        getUserUID(email: email) { contactUid in
            guard let contactUid = contactUid else { return }
            Firestore.firestore().collection("contacts").document(currentUser.uid).collection("items").document(contactUid).updateData([
                "fullName": fullName,
                "phoneNumber": phoneNumber,
                "email": email
            ]) { error in
                if let error = error {
                    print("Error update contact user: \(error)")
                }
            }
        }
    }
    
    private func sendNotifications(getUid: String, uid: String, fullName: String, imageURL: String?, senderEmail: String) {
        let notification = NotificationModel(id: uid, fullName: fullName, imageURL: imageURL, requestMessage: "Wants to add you to add to contacts", senderEmail: senderEmail, status: "pending", statusStream: "not started")
        guard let encodedUser = try? Firestore.Encoder().encode(notification) else { return }
        
       let dbRef = db.collection("notifications").document(getUid).collection("items").document(Auth.auth().currentUser?.uid ?? "")
        dbRef.setData(encodedUser)
        dbRef.updateData(["date" : FieldValue.serverTimestamp()])
    }
    
    private func inputsAreNotEmpty(_ inputs: String...) -> Bool {
        for input in inputs {
            if input.isEmpty {
                return false
            }
        }
        return true
    }
    
    func deleteContact(email: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        getUserUID(email: email) { contactUid in
            guard let contactUid = contactUid else { return }
            self.db.collection("contacts").document(currentUser.uid).collection("items").document(contactUid).delete { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                    self.contacts.removeAll { $0.email == email }
                }
            }
        }
    }
    
    private func dateFormatter() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    //MARK: Functions for live stream
    func fetchData(channelName: String) async {
        guard let url = URL(string: "https://agora-token-service-production-76e1.up.railway.app/rtc/\(channelName)/publisher/userAccount/0/") else {
            print("Hey this url doesn't work!!!")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedRes = try? JSONDecoder().decode(TokenModel.self, from: data) {
                token = decodedRes
                AppKeys.agoraToken = token?.rtcToken
            }
        }catch {
            print("Bad news ... this data is not valid")
        }
    }
    
    func joinChannel(channelName: String, streamType: Bool) {
        print(token?.rtcToken ?? "No token")
        print("https://agora-token-service-production-76e1.up.railway.app/rtc/\(channelName)/publisher/userAccount/0/")
        
         AgoraViewerHelper.agview.join(
            channel: channelName, with: token?.rtcToken,
            as: streamType ? .audience : .broadcaster
        )
    }
    
    func getEndOfStreamStatus(channelName: String) {
        let nameForStatus = channelName.replacingOccurrences(of: ".", with: "")
        var ref: DatabaseReference!
        guard let getUUID = NavigationManager.shared.broadcasterData?.broadcasterID else {
            return
        }
        ref = Database.database().reference()
        //MARK: TODO
        ref.child("users").child(getUUID).child("endOfStream").child(nameForStatus).observe(.value) { snapshot in
            self.getEndStatus = snapshot.value as? Bool ?? false
        }
    }
    
    func fetchChannelNameFirestore(completion: @escaping (String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        let collectionRef = Firestore.firestore().collection("contacts").document(currentUser).collection("items")
        
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: error receiving documents from contacts: \(error)")
                completion(nil)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("DEBUG: no documents found in contacts")
                completion(nil)
                return
            }
            
            for document in documents {
                if let channelNameValue = document.data()["channelName"] as? String
                {
                    completion(channelNameValue)
                    print("Channel name for contacts: \(String(describing: channelNameValue))")
                }
            }
        }
    }
    
    // MARK: Stream recording warnings
    @State var recordingID: String = String(abs(UUID().hashValue % 100000))
    var startResponse: StartResponse?
    var channelName: String?
    
    func acquireRequest(channelName: String) {
        guard let url = URL(string: "https://agoracloudrecording-production-0cef.up.railway.app/acquire") else {
            return
        }
        
        print("making api post request")
        
        var request = URLRequest(url: url)
        
        //method, body, headers
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "channel": "\(channelName)",
            "uid": recordingID
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        //make the request
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let response = try JSONDecoder().decode(AcquireResponse.self, from: data)
                print("Success: \(response)")
                self.startRequest(resource: response.resourceId, channelName: channelName)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func startRequest(resource: String, channelName: String) {
        guard let url = URL(string: "https://agoracloudrecording-production-0cef.up.railway.app/start") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        //method, body, headers
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "channel": "\(channelName)",
            "uid": recordingID,
            "mode": "mix",
            "token": token!.rtcToken,
            "resource": resource
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        //make the request
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let response = try JSONDecoder().decode(StartResponse.self, from: data)
                self?.startResponse = response
                self?.channelName = channelName
                print("Success: \(response)")
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func stopRequest() {
        guard let url = URL(string: "https://agoracloudrecording-production-0cef.up.railway.app/stop") else {
            return
        }
        
        print("STOP")
        
        var request = URLRequest(url: url)
        
        //method, body, headers
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "channel": channelName,
            "uid": recordingID,
            "mode": "mix",
            "sid": startResponse!.sid,
            "resource": startResponse!.resourceId
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        //make the request
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let response = try JSONDecoder().decode(StopResponse.self, from: data)
                print("Success: \(response)")
                self?.saveRecording(response: response)
                self?.updateStatusStreamToStop()
            } catch {
                print("Could't finish recording! ")
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func saveRecording(response: StopResponse) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        if let serverResponse = response.serverResponse {
            let asset = AVAsset(url: URL(string: "https://storage.googleapis.com/iguard-5c4b6.appspot.com/\(serverResponse.fileList[0].fileName)")!)
            var seconds = Int(CMTimeGetSeconds(asset.duration))
            let mins = seconds / 60
            seconds = seconds % 60
            print(String(seconds))
            let time = "\(mins):\(seconds < 10 ? "0\(seconds)": String(seconds))"
            getFileSize(url: URL(string: "https://storage.googleapis.com/iguard-5c4b6.appspot.com/\(serverResponse.fileList[0].fileName)")!) { fileSize in
                if let fileSize = fileSize {
                    let fileSizeInMB = Double(fileSize) / (1024.0 * 1024.0)
                    print("File Size: \(fileSizeInMB) MB")
                    
                    db.collection("recordings")
                        .document(userID)
                        .collection("recordings")
                        .document()
                        .setData(["url1": "https://storage.googleapis.com/iguard-5c4b6.appspot.com/\(serverResponse.fileList[0].fileName)",
                                  "url2": "https://storage.googleapis.com/iguard-5c4b6.appspot.com/\(serverResponse.fileList[1].fileName)",
                                  "date": Date(),
                                  "duration": time,
                                  "videoSize": String(format: "%.2f", fileSizeInMB)
                                  
                                 ])
                } else {
                    print("Failed to retrieve file size.")
                }
            }
        }
    }
    
    func updateStatusStreamToStop() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("contacts").document(currentUser).collection("items").getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG ERROR: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                if let contactUid = document.data()["id"] as? String {
                    print("DEBUG ---> CONTACT UID: \(contactUid)")
                    print("DocumentID ---> \(document.documentID)")
                    let collectionRef = Firestore.firestore().collection("notifications").document(contactUid).collection("items")
                    self.listener = collectionRef.whereField("statusStream", isEqualTo: "start").addSnapshotListener { snapshot, error in
                        if let error = error {
                            print("DEBUG ERROR: \(error.localizedDescription)")
                            return
                        }
                        guard let documents = snapshot?.documents else { return }
                        for document in documents {
                            Firestore.firestore().collection("notifications").document(contactUid).collection("items").document(document.documentID).updateData(["statusStream" : "stop"])
                            if let error = error {
                                print("ERROR Notification Document: \(document.documentID) \(error.localizedDescription)")
                                return
                            } else {
                                print("Notification  Document id: \(document.documentID)")
                            }
                        }
                    }
                }
            }
        }
    }

}
