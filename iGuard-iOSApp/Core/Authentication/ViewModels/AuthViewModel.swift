//
//  AuthViewModel.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 1/5/23.
//
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import AuthenticationServices
import CryptoKit

class AuthViewModel: ObservableObject {
    fileprivate var currentNonce: String?
    private let auth = Auth.auth()
    @Published var user: User?
    @Published var displayName = ""
    @Published var nonce = ""
    @Published var messageEmailSignUp = ""
    @Published var messagePasswordSignUp = ""
    @Published var messageEmailSignIn = ""
    @Published var messagePasswordSignIn = ""
    @Published var messageEmailReset = ""
    @Published var userSession: FirebaseAuth.User?
    @Published var isHitTestingEnabled = true
    @Published var isLoading = false
    @Published var isHideNavigationBackButton = true
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        self.userSession = auth.currentUser
        registerAuthStateHandler()
        
    }
    

    func registerAuthStateHandler() {
      if authStateHandler == nil {
        authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
          self.user = user
        }
      }
    }

    
    //MARK: - Sign Up
    func createUser(_ fullName: String, _ email: String, _ password: String, completion: @escaping (Result<Bool, AuthError>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                let error = error as NSError
                if let authErrorCode = AuthErrorCode.Code(rawValue: error.code) {
                    switch authErrorCode {
                    case .emailAlreadyInUse:
                        self.messageEmailSignUp = "This email address is already in use"
                        completion(.failure(.emailAlreadyInUse))
                    case .invalidEmail:
                        self.messageEmailSignUp = "The email address is badly formatted."
                        completion(.failure(.invalidEmail))
                    default:
                        print(error.localizedDescription)
                        completion(.failure(.unknown))
                    }
                }
                if password.count < 6 {
                    self.messagePasswordSignUp = "The password must be 6 characters long or more."
                    completion(.failure(.weakPassword))
                }
                completion(.failure(.unknown))
            }
            guard let user = authResult?.user else {
                return
            }
            print("registered user successfully")
            print("user is \(user)")
            self.uploadUserDataToFirestore(user, email, fullName) { success in
                completion(success)
            }
        }
    }
    
    private func uploadUserDataToFirestore(_ user: User, _ email: String, _ fullName: String, completion: ((Result<Bool, AuthError>) -> Void)? = nil) {
        let data = [
            "email": email,
            "fullName": fullName,
            "uuid": user.uid
        ]
        
        Firestore.firestore().collection("users")
            .document(user.uid)
            .setData(data) { error in
                if let error = error {
                    print("Error uploading user data to Firestore: \(error.localizedDescription)")
                    completion?(.failure(.genericError))
                } else {
                    print("Successfully uploaded user data to Firestore.")
                    completion?(.success(true))
                }
            }
    }
    //MARK: - Sign In
    func signIn(_ email: String, _ password: String, completion: @escaping (Bool) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return}
            if let error = error {
                let error = error as NSError
                if let authErrorCode = AuthErrorCode.Code(rawValue: error.code) {
                    switch authErrorCode {
                    case .invalidEmail:
                        self.messageEmailSignIn = "The email address is badly formatted."
                        print("The email address is badly formatted.")
                    case .wrongPassword:
                        self.messagePasswordSignIn = "Incorrect password or email"
                    default:
                        self.messageEmailSignIn = "\(error.localizedDescription)"
                    }
                }
                completion(false)
            }
            guard let user = authResult?.user else { return }
            self.userSession = user
            print("user successfully auth.")
            print("user is \(user)")
            let pushManager = PushNotificationManager(userID: user.uid)
            pushManager.registerForPushNotifications()
            completion(true)
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.userSession = nil
            print("The user logged out of the account")
        } catch let error {
            print("Error signing out: %@", error.localizedDescription)
        }
    }
    
    func deleteFCMTokenFromFirestore() {
        guard let currentUser = Auth.auth().currentUser else { return }
        PushNotificationManager.removeFcmTokenFirestore(forUserUid: currentUser.uid)
        print("FCM token deleted for user with ID: \(currentUser)")
    }
    
    //MARK: - Reset Password
    func resetPassword(_ email: String, completion: @escaping (Bool) -> Void) {
        guard inputsAreNotEmpty(email) else { return }
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.messageEmailReset = error.localizedDescription
                print(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
     func inputsAreNotEmpty(_ inputs: String...) -> Bool {
        for input in inputs {
            if input.isEmpty {
                return false
            }
        }
        return true
    }
    
    private func checkSymbols(password: String) -> Bool {
        return password.count >= 6
    }
    
    func deleteUser(completion: @escaping (Bool) -> Void) {
        guard let currentUser = auth.currentUser else {
            completion(false)
            return
        }
        
        currentUser.delete { [weak self] error in
            if let error = error {
                print("An error happened auth \(error.localizedDescription)")
                completion(false)
            } else {
                self?.deleteInfoFirestore(user: currentUser, completion: completion)
            }
        }
    }

    func deleteInfoFirestore(user: User, completion: @escaping (Bool) -> Void) {
        let contactsRef = Firestore.firestore().collection("contacts")
        
        Firestore.firestore().collection("users").document(user.uid).delete { error in
            if let error = error {
                print("An error happened firestore \(error.localizedDescription)")
                completion(false)
                return
            }
            
            contactsRef.document(user.uid).collection("items").getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error when getting documents from contact collections: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("NO DOCUMENTS")
                    completion(true)
                    return
                }
                for document in documents {
                    contactsRef.document(document.documentID).collection("items").document(user.uid).delete { error in
                        if let error = error {
                            print("Error deleting document: \(error.localizedDescription)")
                            completion(false)
                            return
                        }
                    }
                    Firestore.firestore().collection("notifications").document(user.uid).collection("items").document(document.documentID).delete()
                }
                completion(true)
            }

        }
    }
    
    //MARK: - Sign In With Apple
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
      request.requestedScopes = [.fullName, .email]
      let nonce = randomNonceString()
      currentNonce = nonce
      request.nonce = sha256(nonce)
    }
    @MainActor
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
      if case .failure(let failure) = result {
          print(failure.localizedDescription)
      }
      else if case .success(let authorization) = result {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
            fatalError("Invalid state: a login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetdch identify token.")
            return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
            return
          }

          let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
          Task {
            do {
                let authResult =  try await Auth.auth().signIn(with: credential)
                await updateDisplayName(for: authResult.user, with: appleIDCredential)
                self.userSession = authResult.user
                let pushManager = PushNotificationManager(userID: authResult.user.uid)
                pushManager.registerForPushNotifications()
                
                UserDefaults.standard.setValue(true, forKey: "isTrialActive")
                
                let expirationDate = Date().addingTimeInterval(3 * 24 * 60 * 60)
                
                UserDefaults.standard.set(expirationDate, forKey: "trialExpirationDate")
            }
            catch {
              print("Error authenticating: \(error.localizedDescription)")
            }
          }
        }
      }
    }
    @MainActor
    func deleteAccount() async -> Bool {
    guard let user = user else { return false }
      guard let lastSignInDate = user.metadata.lastSignInDate else { return false }
        let needsReauth = !lastSignInDate.isWithinPast(minutes: 5)

      let needsTokenRevocation = user.providerData.contains(where: { $0.providerID == "apple.com" })

      do {
          
        if needsReauth || needsTokenRevocation {
            print("true")
          let signInWithApple = SignInWithAppleMate()
          let appleIDCredential = try await signInWithApple()

          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetdch identify token.")
            return false
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
            return false
          }

          let nonce = randomNonceString()
          let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)

          if needsReauth {
              try await user.reauthenticate(with: credential)
          }
            if needsTokenRevocation {
                guard let authorizationCode = appleIDCredential.authorizationCode else { return false }
                guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return false }
                isLoading = true
                isHitTestingEnabled = false
                try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
            }
        }
          DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
              self.isLoading = false
              self.userSession = nil
              self.deleteInfoFirestore(user: user) { _ in }
              self.isHitTestingEnabled = true
              Task {
                  try await user.delete()
              }
          }
          return true
      }
        catch let error {
            let errorString = String(describing: error)
            print("An error occurred: \(errorString)")
            return false
        }
    }
    @MainActor
    func updateDisplayName(for user: User, with appleIDCredential: ASAuthorizationAppleIDCredential, force: Bool = false) async {
      if let currentDisplayName = Auth.auth().currentUser?.displayName, !currentDisplayName.isEmpty {
        // current user is non-empty, don't overwrite it
      }
      else {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = appleIDCredential.displayName()
        do {
          try await changeRequest.commitChanges()
            if let displayName = Auth.auth().currentUser?.displayName, let userEmail = user.email {
                uploadUserDataToFirestore(user, userEmail, displayName)
            }
        }
        catch {
          print("Unable to update the user's displayname: \(error.localizedDescription)")
        }
      }
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}

class SignInWithAppleMate: NSObject, ASAuthorizationControllerDelegate {
  private var continuation : CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

  func callAsFunction() async throws -> ASAuthorizationAppleIDCredential {
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.performRequests()
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
      continuation?.resume(returning: appleIDCredential)
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    continuation?.resume(throwing: error)
  }
}

extension Date {
  func isWithinPast(minutes: Int) -> Bool {
      if #available(iOS 15, *) {
          let now = Date.now
          let timeAgo = Date.now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
          let range = timeAgo...now
          return range.contains(self)
      } else {
          print("Warning: isWithinPast() may not work correctly on this version of iOS.")
          let now = Date()
          let timeAgo = now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
          return self > timeAgo
      }
  }
}

enum AuthError: Error {
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail
    case unknown
    case genericError
}
extension ASAuthorizationAppleIDCredential {
  func displayName() -> String {
    return [self.fullName?.givenName, self.fullName?.familyName]
      .compactMap( {$0})
      .joined(separator: " ")
  }
}
