//
//  DriverLicenseModel.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 12/7/23.
//

import Foundation

struct DriverLicenseModel: Hashable, Identifiable, Codable {
    let id: String
    let name: String
    let image: String?
    let lastName: String
    let dateOfBirth: String
    let issueDate: String
    let expirationDate: String
    let state: String
    let drivingClass: String
    let documentID: String
}
