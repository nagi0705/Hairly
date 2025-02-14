import Foundation

struct Message: Codable, Identifiable {
    var id: String = UUID().uuidString
    var text: String
    var timestamp: Date
    var recommendedProducts: [RecommendedProduct]? // 🔥 追加
}
