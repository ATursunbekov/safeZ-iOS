import Foundation
import AVFoundation
import FirebaseFirestore
import FirebaseAuth
import AgoraRtcKit
import AgoraUIKit
import FirebaseDatabase

class HomeViewModel: ObservableObject {
    @Published var currentUserFullName: String = ""
    @Published var firstName = ""
    @Published var currentUserEmail: String = ""
    @Published var avatarUser: URL?
    @Published var avatarAsString: String?
    @Published var firstLetter: Character = " "
    @Published var imageURLs: [String] = []
    @Published var userUid: String = ""
    @Published var checkIsUnread = false
    @Published var infoDriverLicense: [DriverLicenseModel] = []
    private var db = Firestore.firestore()
    var listener: ListenerRegistration?
    
    //MARK: Stream vars
    private var channelName = UUID().uuidString
    private var token: TokenModel?
    var startResponse: StartResponse?
    var stopResponse: StopResponse?
    
    init() {
        getDocuments()
        getDriverLicenseInfo()
    }
    
    deinit {
        print("deinit")
    }
    //var stream status
    var endStreamStatus = false
    
    func regeneateUUID() {
        channelName = UUID().uuidString
    }
    
    func getChannelName() -> String {
        return channelName
    }
    
    func fetchData() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        userUid = currentUserUid
        db.collection("users").document(currentUserUid).addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot else {
                print("Error fetching document: \(String(describing: error))")
                return
            }
            guard let fullName = document.data()?["fullName"] as? String else {
                print("Document data was empty.")
                return
            }
            self.currentUserFullName = fullName
            self.firstName = self.formatInitials(from: self.currentUserFullName)
            
            guard let email = document.data()?["email"] as? String  else {
                print("Document data was empty.")
                return
            }
            self.currentUserEmail = email
            guard let avatarUser = document.data()?["avatar"] as? String  else {
                self.avatarUser = nil
                return
            }
            self.avatarUser = URL(string: avatarUser)
            self.avatarAsString = avatarUser
        }
    }
    
    func getDocuments() {
        imageURLs = []
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(currentUserUid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot?.data() else {
                print("Document not found")
                return
            }
            
            if let imageURLRegistration = document["image_url_registration"] as? String {
                self?.imageURLs.append(imageURLRegistration)
            }
            
            if let imageURLInsurance = document["image_url_insurance"] as? String {
                self?.imageURLs.append(imageURLInsurance)
            }
        }
    }
    
     func getDriverLicenseInfo() {
        guard let currentUser = Auth.auth().currentUser else { return }
         db.collection("documents").document(currentUser.uid).collection("drivingLicense").document(currentUser.uid).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            if let document = documentSnapshot, document.exists, let data = document.data() {
                let id = data["id"] as? String ?? ""
                let name = data["name"] as? String ?? ""
                let lastName = data["lastName"] as? String ?? ""
                let dateOfBirth = data["dateOfBirth"] as? String ?? ""
                let issueDate = data["issueDate"] as? String ?? ""
                let expirationDate = data["expirationDate"] as? String ?? ""
                let state = data["state"] as? String ?? ""
                let drivingClass = data["drivingClass"] as? String ?? ""
                let documentID = data["documentID"] as? String ?? ""
                let avatar = data["image"] as? String ?? ""
                let driverLicenseModel = DriverLicenseModel(id: id, name: name, image: avatar, lastName: lastName, dateOfBirth: dateOfBirth, issueDate: issueDate, expirationDate: expirationDate, state: state, drivingClass: drivingClass, documentID: documentID)
                if self.infoDriverLicense.isEmpty {
                    self.infoDriverLicense.append(driverLicenseModel)
                } else {
                    self.infoDriverLicense[0] = driverLicenseModel
                }
            } else {
                let defaultModel = DriverLicenseModel(id: "", name: "", image: "", lastName: "", dateOfBirth: "", issueDate: "", expirationDate: "", state: "", drivingClass: "", documentID: "")
                self.infoDriverLicense.append(defaultModel)
            }
        }
    }

    
    private func formatInitials(from fullName: String) -> String {
        let nameComponents = fullName.components(separatedBy: " ")
        let words = fullName.split(separator: " ")
        if words.count >= 2{
            if let firstName = nameComponents.first?.capitalized, let lastName = nameComponents.last {
                let formattedLastName = String(lastName.prefix(1).capitalized)
                return "\(firstName) \(formattedLastName)."
            }
        } else {
            return nameComponents.first?.capitalized ?? "No name"
        }

        return ""
    }
    
    // MARK: Live Stream Logic
    
    func joinChannel() {
        print(token != nil ? "Start": "Empty token")
        AgoraViewerHelper.agview.join(
            //channel: channelName, with: AppKeys.agoraToken,
            channel: channelName, with: token?.rtcToken,
            as: .broadcaster
        )
        print("End")
    }
    
    func fetchAgoraToken() async {
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
    
    //MARK: REcording part
    
    
    func acquireRequest() {
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
            "uid": "45687"
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
                self.startRequest(resource: response.resourceId)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func startRequest(resource: String) {
        setEndOfStreamStatus()
        print(token != nil ? "Start": "Empty token")
        guard let url = URL(string: "https://agoracloudrecording-production-0cef.up.railway.app/start") else {
            return
        }
        
        print("making api post request")
        
        var request = URLRequest(url: url)
        
        //method, body, headers
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "channel": "\(channelName)",
            "uid": "45687",
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
                print("Success: \(response)")
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func stopRequest() {
        setEndOfStreamStatus()
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
            "uid": "45687",
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
    
    func setEndOfStreamStatus() {
        let nameForStatus = channelName.replacingOccurrences(of: ".", with: "")
        var ref: DatabaseReference!
        ref = Database.database().reference()
        guard let userID = Auth.auth().currentUser?.uid else {return}
        if !endStreamStatus {
            endStreamStatus = true
            let streamStatusRef = ref.child("users").child(userID).child("endOfStream").child("\(nameForStatus)")
            streamStatusRef.setValue(true) { error, _ in
                if let error = error {
                    // Handle the error if any
                    print("Error updating stream status: \(error.localizedDescription)")
                } else {
                    // Stream status updated successfully
                    print("Stream started")
                }
            }
        } else {
            endStreamStatus = false
            let streamStatusRef = ref.child("users").child(userID).child("endOfStream").child("\(nameForStatus)")
            streamStatusRef.removeValue() { error, _ in
                if let error = error {
                    // Handle the error if any
                    print("Error updating stream status: \(error.localizedDescription)")
                } else {
                    // Stream status updated successfully
                    print("Stream started")
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
    
    func sendNotificationMyContacts(streamType: Bool) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        let collectionRef = db.collection("contacts").document(currentUser).collection("items").whereField("status", in: ["accepted", ""])
        let contactsCollection = db.collection("contacts").document(currentUser).collection("items")
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: error receiving documents from contacts: \(error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("DEBUG: no documents found in contacts")
                return
            }
            for document in documents {
                if let uidContacts = document.data()["id"] as? String {
                    self.getFCMToken(for: uidContacts, streamType: streamType)
                    self.sendNotificationToView(for: uidContacts)
                }
                contactsCollection.document(document.documentID).setData([
                    "channelName": self.channelName,
                    "broadcasterName": self.currentUserFullName,
                    "broadcasterAvatar": self.avatarAsString ?? "-",
                    "time": Date()
                ], merge: true) { error in
                    if let error = error {
                        print("Error when writing data for a document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("The value is successfully written for the document \(document.documentID)")
                    }
                }
            }
        }
    }
    
    func sendNotificationMyContacts() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        let collectionRef = db.collection("contacts").document(currentUser).collection("items").whereField("status", in: ["accepted", ""])
        db.collection("contacts").document(currentUser).collection("items")
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: error receiving documents from contacts: \(error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("DEBUG: no documents found in contacts")
                return
            }
            for document in documents {
                if let uidContacts = document.data()["id"] as? String {
                    self.sendPushNotificationsCoordinateToContacts(for: uidContacts)
                }
            }
        }
    }
    
    private func sendNotificationToView(for uidContacts: String) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        
        let firestore = Firestore.firestore()
        let usersCollection = firestore.collection("users")
        let notificationsCollection = firestore.collection("notifications")
        
        usersCollection.document(currentUser).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: Error receiving user: \(error)")
                return
            }
            
            guard let document = snapshot, let data = document.data() else { return }
            
            let fullName = data["fullName"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let image = data["avatar"] as? String
            let notificationModel = NotificationModel(id: currentUser, fullName: fullName, imageURL: image, requestMessage: "Started Live", senderEmail: email, status: "", statusStream: "start")
            
            guard let encodedUser = try? Firestore.Encoder().encode(notificationModel) else { return }
            
            notificationsCollection.document(uidContacts).collection("items").addDocument(data: encodedUser) { error in
                if let error = error {
                    print("Failed to send notification: \(error.localizedDescription)")
                    return
                }
            }
        }
    }
    
    func checkIsUnreadMethod() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let collectionRef = Firestore.firestore().collection("notifications").document(currentUserID).collection("items")
        
        listener = collectionRef.addSnapshotListener { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Failed to fetch documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            let unreadDocuments = documents.filter { $0["isUnread"] as? Bool == true }
            self?.checkIsUnread = !unreadDocuments.isEmpty
        }
    }
    
    func removeListener() {
        listener?.remove()
    }

    private func getFCMToken(for uidContacts: String, streamType: Bool) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uidContacts).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: error receiving documents from users: \(error)")
                return
            }
            guard let userData = snapshot?.data(),
                  let fcmToken = userData["fcmToken"] as? String else {
                print("DEBUG: fcmToken not found for user: -> \(uidContacts)")
                return
            }
            print("FCM Token for user: \(uidContacts): ->  \(fcmToken)")
            self.db.collection("users").document(currentUser).getDocument { snapshot, _ in
                guard let document = snapshot, document.exists, let data = document.data() else {
                    print("Current user document does not exist or has no data")
                    return
                }
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Specify the desired date format
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 4)
                let dateString = dateFormatter.string(from: date)
                
                let fullName = data["fullName"] as? String
                
                PushNotificationSender.shared.sendStreamPushNotificationWithChannelName(to: fcmToken,
                                                                                        title: "\(fullName ?? "") started live",
                                                                                        body: "🔴 Live Now. second try",
                                                                                        broadcasterID: self.userUid,
                                                                                        time: dateString,
                                                                                        streamType: streamType
                )
            }
        }
    }
    

    
    func sendPushNotificationsCoordinateToContacts(for uidContacts: String) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uidContacts).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: error receiving documents from users: \(error)")
                return
            }
            guard let userData = snapshot?.data(),
                  let fcmToken = userData["fcmToken"] as? String else {
                print("DEBUG: fcmToken not found for user: -> \(uidContacts)")
                return
            }
            self.db.collection("users").document(currentUser).getDocument { snapshot, _ in
                guard let document = snapshot, document.exists, let data = document.data() else {
                    return
                }
                
                if let fullName = data["fullName"] as? String,let geoPoint = data["location"] as? GeoPoint {
                    PushNotificationSender.shared.sendMyLocationToContacts(to: fcmToken, title: "\(fullName) send location for contacts", body: "shared live location with you", latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                }
            }
        }
    }
    
//    func setCoordinates(latitude: Double, longitude: Double) {
//        guard let currentUser = Auth.auth().currentUser?.uid else { return }
//        
//        let geoPoint = GeoPoint(latitude: latitude, longitude: longitude)
//        
//        let data: [String: Any] = [
//            "location": geoPoint
//        ]
//        
//        let userDocumentRef = Firestore.firestore().collection("users").document(currentUser)
//        userDocumentRef.setData(data, merge: true) { error in
//            if let error = error {
//                print("Error adding location to Firestore: \(error)")
//            } else {
//                print("Location added to Firestore successfully.")
//            }
//        }
//    }
    
    static func lowercaseFirstLetterAndRemoveWhitespace(_ input: String) -> String {
        // Remove whitespace from the original string
        let trimmedString = input.replacingOccurrences(of: " ", with: "")
        
        // Check if the string is not empty
        guard !trimmedString.isEmpty else {
            return ""
        }
        
        // Lowercase the first letter of the resulting string
        let firstLetterIndex = trimmedString.index(trimmedString.startIndex, offsetBy: 1)
        let firstLetterLowercased = String(trimmedString[..<firstLetterIndex]).lowercased()
        let restOfString = String(trimmedString[firstLetterIndex...])
        
        return firstLetterLowercased + restOfString
    }
}

func getFileSize(url: URL, completion: @escaping (UInt64?) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    
    let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
        if let httpResponse = response as? HTTPURLResponse,
           error == nil,
           let contentLength = httpResponse.allHeaderFields["Content-Length"] as? String,
           let fileSize = UInt64(contentLength) {
            completion(fileSize)
        } else {
            completion(nil)
        }
    }
    task.resume()
}

class AgoraViewerHelper: AgoraVideoViewerDelegate {
    static var agview: AgoraViewer = {
        var agSettings = AgoraSettings()
        agSettings.videoConfiguration = .init(size:  CGSize(width: 375.0, height: 812.0), frameRate: .fps24, bitrate: AgoraVideoBitrateStandard, orientationMode: .fixedPortrait, mirrorMode: .auto)
        agSettings.enabledButtons = []
        //agSettings.buttonPosition = .bottom
        //agSettings.colors.micButtonNormal = UIColor.gray.withAlphaComponent(0.1)
        //agSettings.colors.micButtonSelected = UIColor.gray.withAlphaComponent(0.1)
        agSettings.colors.micFlag = UIColor.white.withAlphaComponent(0.0)
        return AgoraViewer(
            connectionData: AgoraConnectionData(
                appId: AppKeys.agoraAppId, rtcToken: AppKeys.agoraToken
            ),
            style: .grid,
            agoraSettings: agSettings,
            delegate: AgoraViewerHelper.delegate
        )
    }()
    // var streamState = AgoraVideoRemoteState.RawValue()
    static var delegate = AgoraViewerHelper()
}

struct AppKeys {
    static let agoraAppId: String = "2b59cb05fe034d2a806782a881ffb013"
    static var agoraToken: String? = ""
}
