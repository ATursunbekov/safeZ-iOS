//
//  NotificationManager.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 13/6/23.

import Foundation

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var selectedTab: Tabs = .home
    @Published var isOpenLiveStream = false
    @Published var isOpenNotificationView = false
    @Published var isOpenMapView = false
    @Published var channelName = ""
    @Published var latitude = 0.0
    @Published var longitude = 0.0
    @Published var broadcasterData: BroadcasterData?
    
    @Published var broadcasterFinished = false
    @Published var broadcasterStreamOn = true
    @Published var isHiddenStream = true
    private init() {}
    
}
