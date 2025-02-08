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
