//
//  LiveStreamView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 12/5/23.
//

import SwiftUI

struct LiveStreamsSheetView: View {
    let driverLicenseModel: DriverLicenseModel
    
    var body: some View {
        DriverLicenseInfoView(driverLicenseModel: driverLicenseModel)
    }
}
