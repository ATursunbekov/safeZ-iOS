//
//  User.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 9/5/23.
//

import Foundation
struct UserModel: Identifiable {
    let id = UUID().uuidString
    let fullName: String
    let email: String
    let photo: String?
}
