import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @Published var message: String = ""  // 🔥 追加: メッセージをグローバルに管理

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.message = "エラー: \(error.localizedDescription)"
                } else {
                    self.message = "ようこそ！"
                    self.isLoggedIn = true
                }
            }
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.message = "エラー: \(error.localizedDescription)"
                } else {
                    self.message = "おかえり⭐︎"
                    self.isLoggedIn = true
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.message = "また後ほど♪"
                self.isLoggedIn = false
            }
        } catch {
            DispatchQueue.main.async {
                self.message = "エラー: \(error.localizedDescription)"
            }
        }
    }
}
