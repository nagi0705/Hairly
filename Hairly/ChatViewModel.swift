import SwiftUI
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private var db = Firestore.firestore()

    init() {
        fetchMessages()
    }

    // 🔥 Firestore からメッセージを取得
    func fetchMessages() {
        db.collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("メッセージ取得エラー: \(error.localizedDescription)")
                    return
                }

                if let snapshot = snapshot {
                    self.messages = snapshot.documents.compactMap { doc -> Message? in
                        try? doc.data(as: Message.self)
                    }
                }
            }
    }

    // 🔥 Firestore にメッセージを送信
    func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }

        let newMessage = Message(text: text, timestamp: Date())

        do {
            _ = try db.collection("messages").addDocument(from: newMessage)
        } catch {
            print("メッセージ送信エラー: \(error.localizedDescription)")
        }
    }
}

// 📌 ローカルストレージでの保存・読み込み機能（Firebaseとは独立）
class LocalChatViewModel: ObservableObject {
    @Published var messages: [Any] = [] // メッセージ履歴（テキスト・画像両方）

    private let storageKey = "chatMessages"

    init() {
        loadMessages() // 🔥 起動時にデータを読み込む
    }

    // 📌 メッセージ追加
    func addMessage(_ message: Any) {
        messages.append(message)
        saveMessages() // 🔥 追加後に保存
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
}
