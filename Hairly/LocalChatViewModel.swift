import SwiftUI
import CoreML
import Vision
import UIKit

class LocalChatViewModel: ObservableObject {
    @Published var messages: [Any] = [] // メッセージ履歴（テキスト・画像両方）

    private let storageKey = "chatMessages"

    init() {
        loadMessages() // 🔥 起動時にデータを読み込む
    }

    // 📌 メッセージ追加
    func addMessage(_ message: Any) {
        DispatchQueue.main.async {
            self.messages.append(message)
            self.saveMessages() // 🔥 追加後に保存
        }
    }

    // 📌 メッセージを UserDefaults に保存
    private func saveMessages() {
        let messageData = messages.compactMap { message -> Data? in
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

    // 📌 画像を解析して髪型を判定するメソッド
    func classifyHairStyle(image: UIImage) {
        HairClassifier.shared.classify(image: image) { result in
            if let hairStyle = result {
                DispatchQueue.main.async {
                    self.addMessage("認識結果: \(hairStyle)") // 🔥 結果をチャットに追加
                }
            } else {
                print("❌ 髪型分類に失敗しました")
            }
        }
    }
}
