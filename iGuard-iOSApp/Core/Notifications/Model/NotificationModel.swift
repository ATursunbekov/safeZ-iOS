//
//  NotificationModel.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 17/4/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotificationModel: Hashable, Identifiable, Codable {
    var id: String
    let fullName : String
    var imageURL: String?
    var requestMessage: String
    var date = Timestamp()
    let senderEmail: String
    var status: String
    let statusStream: String?
    var isUnread = true
    var location: GeoPoint? = nil
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        return dateFormatter.string(from: date.dateValue())
    }
}
