//
//  LocationManager.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 28/8/23.
//
import MapKit
import CoreLocation
import SwiftUI
import Firebase
import FirebaseFirestore

class LocationManager: NSObject, ObservableObject {
    let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var cityName: String = "AL"
    
    @Published var firstMessage = """
 1. I received a ticket in [State] for [citation type], and
    I want to know how to request a hearing.
 """
     
    @Published var secondMessage = """
 2. I received a ticket in [State] for [citation type], and
    I want to know how to avoid points.
 """
    
    let stateDictionary = [
            "AL": "Alabama",
            "AK": "Alaska",
            "AZ": "Arizona",
            "AR": "Arkansas",
            "CA": "California",
            "CO": "Colorado",
            "CT": "Connecticut",
            "DE": "Delaware",
            "FL": "Florida",
            "GA": "Georgia",
            "HI": "Hawaii",
            "ID": "Idaho",
            "IL": "Illinois",
            "IN": "Indiana",
            "IA": "Iowa",
            "KS": "Kansas",
            "KY": "Kentucky",
            "LA": "Louisiana",
            "ME": "Maine",
            "MD": "Maryland",
            "MA": "Massachusetts",
            "MI": "Michigan",
            "MN": "Minnesota",
            "MS": "Mississippi",
            "MO": "Missouri",
            "MT": "Montana",
            "NE": "Nebraska",
            "NV": "Nevada",
            "NH": "New Hampshire",
            "NJ": "New Jersey",
            "NM": "New Mexico",
            "NY": "New York",
            "NC": "North Carolina",
            "ND": "North Dakota",
            "OH": "Ohio",
            "OK": "Oklahoma",
            "OR": "Oregon",
            "PA": "Pennsylvania",
            "RI": "Rhode Island",
            "SC": "South Carolina",
            "SD": "South Dakota",
            "TN": "Tennessee",
            "TX": "Texas",
            "UT": "Utah",
            "VT": "Vermont",
            "VA": "Virginia",
            "WA": "Washington",
            "WV": "West Virginia",
            "WI": "Wisconsin",
            "WY": "Wyoming"
        ]
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    func sendNotificationMyContacts(latitude: Double, longitude: Double) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        let collectionRef = Firestore.firestore().collection("contacts").document(currentUser).collection("items").whereField("status", in: ["accepted", ""])
        Firestore.firestore().collection("contacts").document(currentUser).collection("items")
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: error receiving documents from contacts: \(error)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("DEBUG: no documents found in contacts")
                return
            }
            for document in documents {
                if let uidContacts = document.data()["id"] as? String {
                    self.sendPushNotificationsCoordinateToContacts(for: uidContacts)
                    self.sendNotificationToView(for: uidContacts, latitude: latitude, longitude: longitude)
                    
                }
            }
        }
    }
    
    private func sendPushNotificationsCoordinateToContacts(for uidContacts: String) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uidContacts).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: error receiving documents from users: \(error)")
                return
            }
            guard let userData = snapshot?.data(),
                  let fcmToken = userData["fcmToken"] as? String else {
                print("DEBUG: fcmToken not found for user: -> \(uidContacts)")
                return
            }
            Firestore.firestore().collection("users").document(currentUser).getDocument { snapshot, _ in
                guard let document = snapshot, document.exists, let data = document.data() else {
                    return
                }
                
                if let fullName = data["fullName"] as? String,let geoPoint = data["location"] as? GeoPoint {
                    PushNotificationSender.shared.sendMyLocationToContacts(to: fcmToken, title: "\(fullName) send location for contacts", body: "shared live location with you", latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                }
            }
        }
    }
    
    private func sendNotificationToView(for uidContacts: String, latitude: Double, longitude: Double) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        
        let firestore = Firestore.firestore()
        let usersCollection = firestore.collection("users")
        let notificationsCollection = firestore.collection("notifications")
        
        usersCollection.document(currentUser).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: Error receiving user: \(error)")
                return
            }
            
            guard let document = snapshot, let data = document.data() else { return }
            
            let fullName = data["fullName"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let image = data["avatar"] as? String
            let notificationModel = NotificationModel(id: currentUser, fullName: fullName, imageURL: image, requestMessage: "shared live location with you", senderEmail: email, status: "location", statusStream: nil, location: GeoPoint(latitude: latitude, longitude: longitude))
            
            guard let encodedUser = try? Firestore.Encoder().encode(notificationModel) else { return }
            
            notificationsCollection.document(uidContacts).collection("items").addDocument(data: encodedUser) { error in
                if let error = error {
                    print("Failed to send notification: \(error.localizedDescription)")
                    return
                }
            }
        }
    }
    
    private func setCoordinates(latitude: Double, longitude: Double) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        
        let geoPoint = GeoPoint(latitude: latitude, longitude: longitude)
        
        let data: [String: Any] = [
            "location": geoPoint
        ]
        
        let userDocumentRef = Firestore.firestore().collection("users").document(currentUser)
        userDocumentRef.setData(data, merge: true) { error in
            if let error = error {
                print("Error adding location to Firestore: \(error)")
            } else {
                print("Location added to Firestore successfully.")
            }
        }
    }
    
    func getCity(lat: Double, long: Double) {
        if lat != 0 && long != 0 {
            // Add below code to get address for touch coordinates.
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: lat, longitude: long)
            geoCoder.reverseGeocodeLocation(location, completionHandler:
                                                {
                placemarks, error -> Void in
                
                // Place details
                guard let placeMark = placemarks?.first else { return }
                if let city = placeMark.administrativeArea {
                    self.cityName = city
                    self.firstMessage = """
                 1. I received a ticket in \(self.stateDictionary[city] ?? "State"), and
                    I want to know how to request a hearing.
                 """
                    self.secondMessage = """
                 2. I received a ticket in \(self.stateDictionary[city] ?? "State"), and
                    I want to know how to avoid points.
                 """
                }
            })
        }
    }
    
}
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        setCoordinates(latitude: lastLocation?.coordinate.latitude ?? 0, longitude: lastLocation?.coordinate.longitude ?? 0)
        getCity(lat: lastLocation?.coordinate.latitude ?? 0, long: lastLocation?.coordinate.longitude ?? 0)
        print(#function, location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG Location Manager: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
        print(#function, "Location authorization status changed to:", statusString)
    }
}
