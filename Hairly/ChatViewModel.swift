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

    // 📌 画像を送信して髪型を分類
    func sendImage(image: UIImage) {
        HairClassifier.shared.classify(image: image) { result, hairStyleInfo in
            DispatchQueue.main.async {
                if let hairStyle = result, let info = hairStyleInfo {
                    let messageText = """
                    🏷 髪型: \(hairStyle)
                    📝 説明: \(info.description)
                    🔧 難易度: \(info.difficulty) | ⏳ 所要時間: \(info.timeRequired)
                    📌 スタイリングのコツ:
                    - \(info.stylingTips.joined(separator: "\n- "))
                    🎨 おすすめのアイテム: \(info.recommendedProducts.joined(separator: ", "))
                    """
                    self.sendMessage(messageText) // 🔥 Firestore に送信
                } else {
                    self.sendMessage("❌ 髪型認識に失敗しました")
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
