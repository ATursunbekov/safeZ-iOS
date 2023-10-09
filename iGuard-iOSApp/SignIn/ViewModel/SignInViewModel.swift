//
//  SignInViewModel.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 20/3/23.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class SignInViewModel: ObservableObject {
    @Published var messageEmail = ""
    @Published var messagePassword = ""
    private let auth = Auth.auth()
    @Published var isAuthenticated: Bool = false
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty && !password.isEmpty else {
            return
        }
        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return}
            if let error = error {
                let error = error as NSError
                if let authErrorCode = AuthErrorCode.Code(rawValue: error.code) {
                    switch authErrorCode {
                    case .invalidEmail:
                        self.messageEmail = "The email address is badly formatted."
                        self.messagePassword = ""
                        print("The email address is badly formatted.")
                    case .wrongPassword:
                        self.messagePassword = "Incorrect password or email"
                        self.messageEmail = ""
                        print("Incorrect password or email")
                    default:
                        self.messageEmail = "\(error.localizedDescription)"
                    }
                }
                completion(false)
            }
            guard let user = authResult?.user else { return }
            print("user successfully auth.")
            print("user is \(user)")
//            self.isAuthenticated = true
//            UserDefaults.standard.set(self.isAuthenticated, forKey: "isAuthenticated")
                completion(true)
        }
    }
    func fetchFirestoreData(completion: @escaping (String?, String?) -> Void) {
      if let userId = auth.currentUser?.uid {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        userRef.getDocument {  (document, error) in
          if let document = document, document.exists {
            let data = document.data()
            let fullName = data?["fullName"] as? String ?? ""
            let email = data?["email"] as? String ?? ""

            // Call the completion handler with the full name and email data.
            completion(fullName, email)
          } else {
            print("Document does not exist")
          }
        }
      }
    }
    func signOut() {
        do {
            try auth.signOut()
//            self.isAuthenticated = false
//            UserDefaults.standard.set(self.isAuthenticated, forKey: "isAuthenticated")
            print("The user logged out of the account")
        } catch let error {
            print("Error signing out: %@", error.localizedDescription)
        }
    }
    func checkAuthentication() {
         if Auth.auth().currentUser != nil {
             isAuthenticated = true
//             UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
         }
     }
}
