//
//  RecordingFetchedData.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 8/6/23.
//

import Foundation

struct RecordingFetchedData: Hashable, Identifiable {
    var id = UUID()
    let documentID: String
    let url1: String
    let url2: String
    let date: Date
    let time: String
    let size: String
}

