import SwiftUI
import PhotosUI // 🔥 PhotosPicker を使うために追加

struct ChatView: View {
    @State private var messageText: String = "" // メッセージ入力用
    @State private var selectedItem: PhotosPickerItem? = nil // 🔥 選択された写真データを管理
    @State private var selectedImage: UIImage? = nil // 🔥 選択した写真を UIImage に変換して保持
    @StateObject private var viewModel = LocalChatViewModel() // 🔥 ViewModel を追加

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
                .onChange(of: viewModel.messages.count) { _ in
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
                .onChange(of: selectedItem) { newItem in
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
                        viewModel.addMessage(uiImage) // 🔥 ViewModel に追加して保存
                    }
                case .failure(let error):
                    print("写真のロードエラー: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    ChatView()
}
