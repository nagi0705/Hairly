import SwiftUI
import PhotosUI

struct ChatView: View {
    @State private var messageText: String = "" // メッセージ入力用
    @State private var messages: [Any] = [] // メッセージ履歴（テキスト・画像両方対応）
    @State private var selectedImage: UIImage? = nil // 選択した画像
    @State private var isImagePickerPresented: Bool = false // Pickerの表示管理

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(messages.indices, id: \.self) { index in
                        if let text = messages[index] as? String {
                            Text(text)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if let image = messages[index] as? UIImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.indices.last {
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

                // 📌 写真送信ボタン
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage, onImagePicked: sendImage)
                }
            }
            .padding()
        }
        .navigationTitle("チャット")
    }

    // 📌 メッセージ送信処理
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        messages.append(messageText) // メッセージを配列に追加
        messageText = "" // 入力フィールドをリセット
    }

    // 📌 画像送信処理
    func sendImage(image: UIImage) {
        messages.append(image) // 画像を配列に追加
    }
}

// 📌 `PhotosPicker` 用のカスタム ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImagePicked: (UIImage) -> Void // 🔥 画像が選択されたら呼ばれるクロージャ

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.onImagePicked(uiImage) // 🔥 画像を送信
                parent.selectedImage = nil // 選択画像をリセット
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    ChatView()
}
