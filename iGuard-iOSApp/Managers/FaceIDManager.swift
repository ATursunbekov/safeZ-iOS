//
//  FaceIDManager.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 10/7/23.
//

import Foundation
import LocalAuthentication

class FaceIDAuthenticationManager {
    static func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Enter your passcode"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true)
                    } else {
                        completion(false)

                        if let error = authenticationError as NSError? {
                            if error.code == LAError.userFallback.rawValue {
                                // Обработка отката к другому способу аутентификации (например, паролю)
                            }
                        }
                    }
                }
            }
        } else {
            completion(false)
        }
    }
}
