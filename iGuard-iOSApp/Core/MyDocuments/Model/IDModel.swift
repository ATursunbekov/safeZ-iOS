import Foundation

struct IDModel: Hashable, Identifiable, Codable {
    let id: String
    let name: String
    var lastName: String
    var dateOfBirth: String
    let issueDate: String
    let expirationDate: String
    let state: String
    let documentID: String
}
