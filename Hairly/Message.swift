import Foundation

struct Message: Identifiable, Codable {
    var id: String? // Firestore の documentID を格納する
    var text: String
    var timestamp: Date

    init(id: String? = nil, text: String, timestamp: Date) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
    }
}
