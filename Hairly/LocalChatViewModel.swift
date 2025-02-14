import SwiftUI
import UIKit

class LocalChatViewModel: ObservableObject {
    @Published var messages: [Any] = [] // テキストと画像の履歴
    private let storageKey = "chatMessages"
    private let maxHistoryCount = 10 // 🔥 最大保存件数を10件に制限

    init() {
        loadMessages()
    }

    // 📌 メッセージ追加
    func addMessage(_ message: Any) {
        DispatchQueue.main.async {
            self.messages.append(message)
            self.saveMessages()
        }
    }

    // 📌 メッセージ履歴を UserDefaults に保存（最新10件のみ）
    private func saveMessages() {
        let trimmedMessages = messages.suffix(maxHistoryCount) // 🔥 最新10件のみ保存
        let messageData = trimmedMessages.compactMap { message -> Data? in
            if let text = message as? String {
                return try? JSONEncoder().encode(["type": "text", "content": text])
            } else if let image = message as? UIImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                return try? JSONEncoder().encode(["type": "image", "content": imageData.base64EncodedString()])
            }
            return nil
        }
        UserDefaults.standard.set(messageData, forKey: storageKey)
    }

    // 📌 保存されたメッセージを読み込む
    private func loadMessages() {
        guard let savedData = UserDefaults.standard.array(forKey: storageKey) as? [Data] else { return }
        messages = savedData.compactMap { data in
            if let decoded = try? JSONDecoder().decode([String: String].self, from: data),
               let type = decoded["type"], let content = decoded["content"] {
                if type == "text" {
                    return content
                } else if type == "image", let imageData = Data(base64Encoded: content), let image = UIImage(data: imageData) {
                    return image
                }
            }
            return nil
        }
    }

    // 📌 画像を解析して髪型を判定
    func classifyHairStyle(image: UIImage) {
        HairClassifier.shared.classify(image: image) { result, hairStyleInfo in
            DispatchQueue.main.async {
                if let hairStyle = result, let info = hairStyleInfo {
                    let message = """
                    🏷 髪型: \(hairStyle)
                    📝 説明: \(info.description)
                    🔧 難易度: \(info.difficulty) | ⏳ 所要時間: \(info.timeRequired)
                    📌 スタイリングのコツ:
                    - \(info.stylingTips.joined(separator: "\n- "))
                    🎨 おすすめのアイテム: \(info.recommendedProducts.map { $0.name }.joined(separator: ", "))
                    """
                    self.addMessage(message)
                } else {
                    self.addMessage("❌ 髪型認識に失敗しました")
                }
            }
        }
    }
} 
