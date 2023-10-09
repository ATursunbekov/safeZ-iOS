import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileEditViewModel: ObservableObject {
    // Properties
    @Published var email = ""
    @Published var fullName = ""
    @Published var isLoadingLoader = false
    @Published var isPasswordValid = true
    @Published var messagePassword = ""
    @Published var messageConfirmPassword = ""
    @Published private var currentUser: User?
    @Published var avatarUser: URL?
    @Published var isAppleIDUser = false
    private let db = Firestore.firestore()
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {return}
            self.currentUser = user
            isAppleIDUser = self.checkIfAppleIDUser(user)
            self.getDataUser(fullName: self.fullName, email: self.email)
            self.getAvatarUser()
        }
    }
    
    private var userDocRef: DocumentReference? {
        guard let userId = currentUser?.uid else { return nil }
        return db.collection("users").document(userId)
    }
    
    private var uidName: String {
        guard let userId = currentUser?.uid else { return "" }
        return userId
    }
    
    func uploadImageStorage(path: FolderPath, image: UIImage?, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUser?.uid else {
            completion(false)
            return
        }
        
        guard let image = image else {
            completion(false)
            return
        }
        
        ImageUploader.uploadImage(fileName: uidName, path: path, image: image) { [weak self] imageURLKey, imageUrl in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            
            strongSelf.userDocRef?.updateData([imageURLKey : imageUrl]) { error in
                if let error = error {
                    print("DEBUG: Failed to update user's image URL: \(error.localizedDescription)")
                    completion(false)
                } else {
                    strongSelf.db.collection("documents").document(userId).collection("drivingLicense").document(userId).updateData(["image" : imageUrl]) { error in
                        if let error = error {
                            print("DEBUG: Failed to update document's image URL: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            completion(true)

                        }
                    }
                }
            }
        }
    }

    
    func deleteImageStorage() {
        guard let userId = currentUser?.uid else { return }
        ImageUploader.deleteImage(fileName: uidName, folder: .avatar)
        deleteFieldImage(folder: .avatar)
        db.collection("documents").document(userId).collection("drivingLicense").document(userId).updateData(["image" : FieldValue.delete()])
    }
    
    func getAvatarUser() {
        userDocRef?.addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot else {
                print("User document not found")
                return
            }
            
            if let avatar = document.data()?["avatar"] as? String {
                self?.avatarUser = URL(string: avatar)
            } else {
                self?.avatarUser = nil
            }
        }
    }
    
    func getDataUser(fullName: String, email: String) {
        userDocRef?.getDocument { snapshot, error in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot else {
                print("User document not found")
                return
            }
            if let fullName = document.data()?["fullName"] as? String, let email = document.data()?["email"] as? String{
                self.fullName = fullName
                self.email = email
            }
        }
    }
    
    func updateFullName(completion: @escaping (Bool) -> Void) {
        userDocRef?.updateData(["fullName" : fullName], completion: { error in
            if let error = error {
                print("DEBUG: Failed update fullName user: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Full name updated successfully.")
                completion(true)
            }
        })
    }
    
    func changePassword(newPassword: String, confirmPassword: String, completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser
        guard let user = user else {
            print("No user signed in.")
            completion(false)
            return
        }
        
        guard newPassword.count >= 6 && confirmPassword.count > 6 else {
            messagePassword = "New password must be at least 6 characters long"
            isPasswordValid = false
            completion(false)
            return
        }
        
        guard newPassword == confirmPassword else  {
            messagePassword = "Passwords do not match"
            isPasswordValid = false
            completion(false)
            return
        }
        
        user.updatePassword(to: newPassword) { error in
            if let error = error {
                print("Error changing password: \(error.localizedDescription)")
                self.messagePassword = "\(error.localizedDescription)"
                self.isPasswordValid = false
                completion(false)
            } else {
                print("Password changed successfully.")
                completion(true)
            }
        }
    }


    private func deleteFieldImage(folder: FolderPath) {
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
    
    func checkIfAppleIDUser(_ user: User?) -> Bool {
        guard let user = user else {
            return false
        }
        
        for userInfo in user.providerData {
            if userInfo.providerID == "apple.com" {
                return true
            }
        }
        return false
    }
    
}
