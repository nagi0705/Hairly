import SwiftUI
import PhotosUI // 🔥 PhotosPicker を使うために追加

struct ChatView: View {
    @State private var messageText: String = "" // メッセージ入力用
    @State private var selectedItem: PhotosPickerItem? = nil // 🔥 選択された写真データを管理
    @State private var selectedImage: UIImage? = nil // 🔥 選択した写真を UIImage に変換して保持
    @StateObject private var viewModel = LocalChatViewModel() // 🔥 ViewModel を変更

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.messages.indices, id: \.self) { index in
                        if let text = viewModel.messages[index] as? String {
                            Text(text)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if let image = viewModel.messages[index] as? UIImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let last = viewModel.messages.indices.last {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }

            // 📌 メッセージ入力フィールドと送信ボタン
            HStack {
                TextField("メッセージを入力", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: sendMessage) {
                    Text("送信")
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.trailing)

                // 📌 PhotosPicker を使った写真選択
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                .onChange(of: selectedItem) { oldItem, newItem in
                    loadImage(from: newItem)
                }
            }
            .padding()
        }
        .navigationTitle("チャット")
    }

    // 📌 メッセージ送信処理
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        viewModel.addMessage(messageText) // 🔥 ViewModel で管理
        messageText = "" // 入力フィールドをリセット
    }

    // 📌 選択された写真を UIImage に変換して保存
    func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }

        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        sendImage(image: uiImage) // 🔥 画像を送信
                    }
                case .failure(let error):
                    print("写真のロードエラー: \(error.localizedDescription)")
                }
            }
        }
    }

    // 📌 画像送信処理（修正済み）
    func sendImage(image: UIImage) {
        viewModel.addMessage(image) // 画像をチャットに追加
        
        HairClassifier.shared.classify(image: image) { result, hairStyleInfo in
            DispatchQueue.main.async {
                if let hairStyle = result, let info = hairStyleInfo {
                    let message = """
                    🏷 髪型: \(hairStyle)
                    📝 説明: \(info.description)
                    🔧 難易度: \(info.difficulty) | ⏳ 所要時間: \(info.timeRequired)
                    📌 スタイリングのコツ:
                    - \(info.stylingTips.joined(separator: "\n- "))
                    🎨 おすすめのアイテム: \(info.recommendedProducts.joined(separator: ", "))
                    """
                    viewModel.addMessage(message)
                } else {
                    viewModel.addMessage("❌ 髪型認識に失敗しました")
                }
            }
        }
    }
}

#Preview {
    ChatView()
}
