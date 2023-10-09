import Foundation
import FirebaseStorage
import AVFoundation
import _AVKit_SwiftUI
import FirebaseFirestore
import FirebaseAuth
import SwiftUI


class RecordingViewModel: ObservableObject {
    
    @Published var recordings = [RecordingFetchedData]()
    @Published var isShareSheetShowing = false
    var showLoader = false
    
    func retrieveVideos() {
        showLoader = true
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("recordings")
            .document(userID)
            .collection("recordings")
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error retrieving videos: \(error)")
                    return
                }
                
                if let snapshot = snapshot {
                    var newRecordings = [RecordingFetchedData]()
                    
                    for doc in snapshot.documents {
                        let documentId = doc.documentID
                        let url1 = doc["url1"] as? String ?? ""
                        let url2 = doc["url2"] as? String ?? ""
                        let date = doc["date"] as? Date ?? Date()
                        let time = doc["duration"] as? String ?? ""
                        let size = doc["videoSize"] as? String ?? ""
                        
                        let recordingData = RecordingFetchedData(documentID: documentId, url1: url1, url2: url2, date: date, time: time, size: size)
                        
                        newRecordings.append(recordingData)
                    }
                    
                    //newRecordings.sort{ $0.date > $1.date }
                    DispatchQueue.main.async {
                        self.recordings = newRecordings
                        self.showLoader = false
                    }
                    
                    print("Success: \(self.recordings)!")
                }
            }
    }

    
    func getFileSize(url: URL, completion: @escaping (UInt64?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let httpResponse = response as? HTTPURLResponse,
               error == nil,
               let contentLength = httpResponse.allHeaderFields["Content-Length"] as? String,
               let fileSize = UInt64(contentLength) {
                completion(fileSize)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func deleteRecording(video: RecordingFetchedData) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let docRef = db.collection("recordings")
            .document(userID)
            .collection("recordings")
            .document(video.documentID)
        docRef.delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully deleted!")
            }
        }
        
        // Remove from the main array on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let index = self.recordings.firstIndex(where: { $0.documentID == video.documentID }) {
                withAnimation {
                    self.recordings.remove(at: index)
                }
            }
        }
        
        // Perform remaining tasks on a background queue
        DispatchQueue.global(qos: .background).async {
            self.deleteVideoFromStorage(url: video.url1)
            self.deleteVideoFromStorage(url: video.url2)
            let urlString = video.url2
            if let dotIndex = urlString.lastIndex(of: "."), let startingPoint = urlString.lastIndex(of: "/") {
                let index = urlString.index(startingPoint, offsetBy: 1)
                let fileName =  String(urlString[index ..< dotIndex])
                print(fileName)
                self.fetchMatchingFiles(name: fileName)
            } else {
                print("Invalid URL string")
            }
        }
    }

    
    func deleteVideoFromStorage(url: String) {
        let bucketName = "iguard-5c4b6.appspot.com"
        guard let objectPath = url.components(separatedBy: "/").last else {
            print("Invalid URL: \(url)")
            return
        }
        let storageURL = "gs://\(bucketName)/videos/\(objectPath)"
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: storageURL)
        
        storageRef.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("Error in deleting file: \(error.localizedDescription)")
            } else {
                // File deleted successfully
                print("File deleted successfully")
            }
        }
    }
    func fetchMatchingFiles(name: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://iguard-5c4b6.appspot.com/videos/")
        
        storageRef.listAll { result, error in
            if let error = error {
                print("Error listing files: \(error)")
                return
            }
            
            if let matchingFile = result!.items.last(where: {$0.name.contains(name)} ) {
                    print(matchingFile.name)
                    self.deleteVideoFromStorage(url: matchingFile.name)
            }
        }
    }
    
    func getCurrentDate(recDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: recDate)
        return dateString
    }
}
