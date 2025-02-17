import SwiftUI
import UIKit

class LocalChatViewModel: ObservableObject {
    @Published var messages: [Any] = [] // テキストと画像の履歴
    private let storageKey = "chatMessages"
    private let maxHistoryCount = 10 // 🔥 最大保存件数を10件に制限

    // 最新の髪型履歴を管理するためのプロパティ
    private let maxHairHistoryCount = 3
    private var hairStyleHistory: [String] = []
    private let hairHistoryStorageKey = "hairStyleHistory"

    init() {
        loadMessages()
        loadHairHistory()
    }

    // 📌 メッセージ履歴を UserDefaults から読み込む
    private func loadMessages() {
        guard let savedData = UserDefaults.standard.array(forKey: storageKey) as? [Data] else { return }
        messages = savedData.compactMap { data in
            if let decoded = try? JSONDecoder().decode([String: String].self, from: data),
               let type = decoded["type"], let content = decoded["content"] {
                if type == "text" {
                    return content
                } else if type == "image",
                          let imageData = Data(base64Encoded: content),
                          let image = UIImage(data: imageData) {
                    return image
                }
            }
            return nil
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

    // 髪型履歴の読み込みメソッド
    private func loadHairHistory() {
        if let savedHistory = UserDefaults.standard.array(forKey: hairHistoryStorageKey) as? [String] {
            hairStyleHistory = savedHistory
        }
    }

    // 髪型履歴の保存メソッド
    private func saveHairHistory() {
        UserDefaults.standard.set(hairStyleHistory, forKey: hairHistoryStorageKey)
    }

    // 髪型履歴を更新するメソッド
    private func updateHairHistory(with newHairStyle: String) {
        // すでに同じ髪型が存在する場合は削除
        if let index = hairStyleHistory.firstIndex(of: newHairStyle) {
            hairStyleHistory.remove(at: index)
        }
        
        // 新しい髪型を先頭に挿入
        hairStyleHistory.insert(newHairStyle, at: 0)
        
        // 履歴の件数が上限を超えた場合、古いものを削除
        if hairStyleHistory.count > maxHairHistoryCount {
            hairStyleHistory = Array(hairStyleHistory.prefix(maxHairHistoryCount))
        }
        
        // 更新後、UserDefaults に保存
        saveHairHistory()
    }

    // 📌 メッセージ追加
    func addMessage(_ message: Any) {
        DispatchQueue.main.async {
            self.messages.append(message)
            self.saveMessages()
        }
    }

    // 📌 画像を解析して髪型を判定し、スタイリングアドバイスを追加
    func classifyHairStyle(image: UIImage) {
        HairClassifier.shared.classify(image: image) { result, hairStyleInfo in
            DispatchQueue.main.async {
                if let hairStyle = result, let info = hairStyleInfo {
                    // 💡 スタイリングアドバイスを取得
                    let stylingAdvice = HairStyleManager.shared.getStylingAdvice(for: hairStyle)
                    
                    // ここで髪型履歴の更新を実施
                    self.updateHairHistory(with: hairStyle)
                    
                    // 🔍 デバッグログ: 取得したスタイリングアドバイスを確認
                    print("📢 取得したスタイリングアドバイス (\(hairStyle)): \(stylingAdvice)")
                    
                    let message = """
                    🏷 **髪型**: \(hairStyle)
                    📝 **説明**: \(info.description)
                    🔧 **難易度**: \(info.difficulty) | ⏳ **所要時間**: \(info.timeRequired)
                    
                    📌 **スタイリングのコツ**:
                    - \(info.stylingTips.joined(separator: "\n- "))
                    
                    ✨ **スタイリングアドバイス**:
                    \(stylingAdvice.isEmpty ? "スタイリングアドバイスが見つかりません" : "- " + stylingAdvice.joined(separator: "\n- "))
                    
                    🎨 **おすすめのアイテム**: \(info.recommendedProducts.map { $0.name }.joined(separator: ", "))
                    """
                    
                    print("📢 送信するメッセージ: \(message)") // 🔍 デバッグログ
                    
                    self.addMessage(message)
                } else {
                    self.addMessage("❌ 髪型認識に失敗しました")
                }
            }
        }
    }
}
