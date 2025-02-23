import Foundation
import Combine

class HairTrendNewsViewModel: ObservableObject {
    @Published var news: [HairTrendNews] = []
    
    init() {
        loadNews()
    }
    
    func loadNews() {
        // Bundle から HairTrendNews.json を取得
        if let url = Bundle.main.url(forResource: "HairTrendNews", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let newsItems = try decoder.decode([HairTrendNews].self, from: data)
                DispatchQueue.main.async {
                    self.news = newsItems
                }
            } catch {
                print("ニュースデータの読み込みに失敗しました: \(error)")
            }
        } else {
            print("HairTrendNews.json が見つかりません")
        }
    }
}
