//
//  AcquireModel.swift
//  tempreture
//
//  Created by Alikhan Tursunbekov on 31/5/23.
//

import Foundation

struct AcquireResponse: Codable {
    let resourceId: String
}
struct StartResponse: Codable {
    let resourceId: String
    let sid: String
}

struct StopResponse: Codable {
    let resourceId: String
    let sid: String
    let serverResponse: ServerResponse?
}

struct ServerResponse: Codable {
    let fileListMode: String
    let fileList: [FileList]
    let uploadingStatus: String
}

struct FileList: Codable {
    let fileName: String
    let isPlayable: Bool
    let mixedAllUser: Bool
    let sliceStartTime: Int64
    let trackType: String
    let uid: String
}
