//
//  ProfileModel.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 10/4/23.
//

import Foundation
struct ProfileModel: Identifiable {
    let id = UUID().uuidString
    let title: String
    let image: String
}
