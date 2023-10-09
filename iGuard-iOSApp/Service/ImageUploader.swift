//
//  ImageUploader.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 11/5/23.
//

import Foundation
import FirebaseStorage
struct ImageUploader {
    
    static func uploadImage(fileName: String ,path: FolderPath ,image: UIImage?, completion: @escaping(String, String) -> Void) {
        guard let imageData = image?.jpegData(compressionQuality: 0.6) else {return }
        var storageRef = Storage.storage().reference()
        var imageURLKey: String
        switch path {
        case .avatar:
            storageRef = storageRef.child("avatars/\(fileName).jpg")
            imageURLKey = "avatar"
        case .carRegistration:
            storageRef = storageRef.child("vehicle registration/\(fileName).jpg")
            imageURLKey = "image_url_registration"
        case .carInsurance:
            storageRef = storageRef.child("car insurance/\(fileName).jpg")
            imageURLKey = "image_url_insurance"
        }
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: Failed to upload image with error: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { imageUrl, _ in
                guard let imageUrl = imageUrl?.absoluteString else { return }
                print("success")
                completion(imageURLKey, imageUrl)
            }
        }
    }
    static func deleteImage(fileName: String,folder: FolderPath) {
        var storageRef = Storage.storage().reference()
        switch folder {
        case .avatar:
            storageRef = storageRef.child("avatars/\(fileName).jpg")
        case .carRegistration:
            storageRef = storageRef.child("vehicle registration/\(fileName).jpg")
        case .carInsurance:
            storageRef = storageRef.child("car insurance/\(fileName).jpg")
        }
        storageRef.delete { error in
            if let error = error {
                print("File deletion error:\(error.localizedDescription)")
            } else {
                print("File has been successfully deleted")
            }
        }
    }
}

enum FolderPath: String {
    case avatar = "avatar"
    case carRegistration = "image_url_registration"
    case carInsurance = "image_url_insurance"
}
