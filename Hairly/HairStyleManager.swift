import Foundation

// スタイリング製品情報を管理する構造体
struct RecommendedProduct: Codable {
    let name: String   // 製品名
    let type: String   // 製品の種類（例: ワックス, ヘアスプレー）
    let url: String    // 製品の詳細ページURL
}

// 髪型情報を管理する構造体
struct HairStyle: Codable {
    let description: String            // 髪型の説明
    let difficulty: String             // 難易度
    let timeRequired: String           // セットにかかる時間
    let stylingTips: [String]          // スタイリングのアドバイス
    let recommendedProducts: [RecommendedProduct] // おすすめの製品（最大2つ）
}

// 髪型データを管理するクラス
class HairStyleManager {
    static let shared = HairStyleManager()
    private var hairStyles: [String: HairStyle] = [:]

    private init() {
        loadHairStyles()
    }

    private func loadHairStyles() {
        if let url = Bundle.main.url(forResource: "HairStyleData", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([String: HairStyle].self, from: data) {
                hairStyles = decodedData
            }
        }
    }

    // 指定した髪型の情報を取得
    func getHairStyle(for type: String) -> HairStyle? {
        return hairStyles[type]
    }

    // 指定した髪型に対応するおすすめの製品リストを取得
    func getRecommendedProducts(for type: String) -> [RecommendedProduct]? {
        return hairStyles[type]?.recommendedProducts
    }
}

