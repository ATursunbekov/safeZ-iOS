//
//  MapView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 28/8/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var latitude: Double
    @State private var longitude: Double
    @State private var region: MKCoordinateRegion
    private var locations: [Location]
    @Environment(\.presentationMode) var presentationMode
    @StateObject var locationManager = LocationManager()
    
    init(latitude: Double, longitude: Double) {
        self._latitude = State(initialValue: latitude)
        self._longitude = State(initialValue: longitude)
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        self.locations = [Location(name: "Aidar", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))]
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: locations) { location in
                MapMarker(coordinate: location.coordinate)
            }
            .ignoresSafeArea()
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 30))
                    .padding(25)
                    .foregroundColor(.black)
            }
            
        }
        .navigationBarHidden(true)
    }
}

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
