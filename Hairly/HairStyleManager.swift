import Foundation

struct HairStyle: Codable {
    let description: String
    let difficulty: String
    let timeRequired: String
    let stylingTips: [String]
    let recommendedProducts: [String]
}

class HairStyleManager {
    static let shared = HairStyleManager()
    private var hairStyleData: [String: HairStyle] = [:]

    private init() {
        loadHairStyleData()
    }

    private func loadHairStyleData() {
        guard let url = Bundle.main.url(forResource: "HairStyleData", withExtension: "json") else {
            print("❌ 髪型データのファイルが見つかりません")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            hairStyleData = try JSONDecoder().decode([String: HairStyle].self, from: data)
            print("✅ 髪型データをロードしました: \(hairStyleData.keys)")
        } catch {
            print("❌ 髪型データの読み込みに失敗しました: \(error)")
        }
    }

    func getHairStyleInfo(for name: String) -> HairStyle? {
        return hairStyleData[name]
    }
}
