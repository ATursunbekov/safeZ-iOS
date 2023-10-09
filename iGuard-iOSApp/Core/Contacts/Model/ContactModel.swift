//
//  ContactModel.swift
//  iGuardApp
//
//  Created by Alikhan Tursunbekov on 7/4/23.
//

import Foundation

struct ContactModel: Hashable, Identifiable, Codable {
    let id: String
    var fullName: String
    var phoneNumber: String
    let email: String
    let status: String
    var image: String?
}
