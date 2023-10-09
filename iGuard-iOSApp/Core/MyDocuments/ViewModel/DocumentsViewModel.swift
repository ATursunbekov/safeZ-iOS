//
//  DocumentsViewModel.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 2/5/23.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class DocumentsViewModel: ObservableObject {
    
    @Published var imageURLRegistration: URL?
    @Published var imageURLInsurance: URL?
    @Published var isLoadingLoader = false
    @Published private var currentUser: User?
    @Published var dataArray: [String] = ["?", "?","?","?","?","?","?","?","?"]
    private let db = Firestore.firestore()
    
    private var userDocRef: DocumentReference? {
        guard let userId = currentUser?.uid else { return nil }
        return db.collection("users").document(userId)
    }
    
    var uidName: String {
        guard let userId = currentUser?.uid else { return "" }
        return userId
    }
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {return}
            self.currentUser = user
            self.loadImageUrl()
        }
    }
    
    func uploadImageStorage(path: FolderPath, image: UIImage, completion: @escaping ((Bool) -> Void)) {
        isLoadingLoader = true
        ImageUploader.uploadImage(fileName: uidName, path: path, image: image) { [weak self] imageURLKey, imageUrl in
            guard let strongSelf = self else { return }
            strongSelf.userDocRef?.updateData([imageURLKey : imageUrl])
            strongSelf.isLoadingLoader = false
            completion(true)
        }
    }
    
    func loadImageUrl() {
        userDocRef?.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()!
                if let imageUrlStringRegistration = data["image_url_registration"] as? String {
                    self.imageURLRegistration = URL(string: imageUrlStringRegistration)
                }
                if let imageUrlStringInsurance = data["image_url_insurance"] as? String {
                    self.imageURLInsurance = URL(string: imageUrlStringInsurance)
                }
            }
        }
    }
    
    func deleteImage(folder: FolderPath) {
        ImageUploader.deleteImage(fileName: uidName, folder: folder)
    }
    func deleteFieldImage(folder: FolderPath) {
        let data: [String: Any] = [
            folder.rawValue: FieldValue.delete()
        ]
        userDocRef?.updateData(data) { error in
            if let error = error {
                print("Error removing image URL: \(error.localizedDescription)")
            } else {
                print("Image URL removed successfully.")
            }
        }
    }
    
    func saveDriverLicense(state: String, drivingClass: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        self.db.collection("users").document(userID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let document = document, document.exists, let data = document.data() {
                let avatar = data["avatar"] as? String ?? ""
                let driverLicenseModel = DriverLicenseModel(id: userID, name: dataArray[0], image: avatar, lastName: dataArray[1], dateOfBirth: dataArray[3], issueDate: dataArray[4], expirationDate: dataArray[5], state: state, drivingClass: drivingClass, documentID: dataArray[6])
                
                guard let encodedUser = try? Firestore.Encoder().encode(driverLicenseModel) else { return }
                db.collection("documents").document(userID).collection("drivingLicense").document(userID).setData(encodedUser)
            } else {
                print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func saveID(state: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let idModel = IDModel(id: userID, name: dataArray[0], lastName: dataArray[1], dateOfBirth: dataArray[3], issueDate: dataArray[4], expirationDate: dataArray[5], state: state, documentID: dataArray[6])
        guard let encodedUser = try? Firestore.Encoder().encode(idModel) else { return }
        db.collection("documents").document(userID).collection("id").document(userID).setData(encodedUser)
    }
}
