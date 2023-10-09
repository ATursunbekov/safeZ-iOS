//
//  UserViewModel.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 22/3/23.
//

import FirebaseAuth
import FirebaseFirestore

class ProfileInfoViewModel: ObservableObject {
    @Published var profileTabsArray = [ProfileModel]()
    @Published var fullName: String?
    @Published var email: String?
    init() {
        fetchProfileTabs()
    }
    private func fetchProfileTabs() {
        let profileTabs = [
            ProfileModel(title: "My Recordings", image: ProfileIcons.videoRecording.rawValue),
            ProfileModel(title: "My Documents", image: ProfileIcons.documents.rawValue),
            ProfileModel(title: "My Subscription", image: ProfileIcons.subscription.rawValue),
            ProfileModel(title: "Settings", image: ProfileIcons.settings.rawValue),
            ProfileModel(title: "Terms of use", image: ProfileIcons.termsOfUse.rawValue),
            ProfileModel(title: "Share", image: ProfileIcons.share.rawValue),
            ProfileModel(title: "Logout", image: ProfileIcons.logout.rawValue)
        ]
        profileTabsArray.append(contentsOf: profileTabs)
    }
}
