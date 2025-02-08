import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @Published var logoutMessage: String = "" // 🔥 ログアウトメッセージ
    @Published var isNewUser: Bool = false   // 🔥 追加

    func signUp(email: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let _ = result {
                self.isLoggedIn = true
                self.isNewUser = true  // 🔥 新規ユーザーのフラグを立てる
                self.logoutMessage = "ようこそ！"
                completion()
            }
        }
    }

    func login(email: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let _ = result {
                self.isLoggedIn = true
                self.isNewUser = false  // 🔥 既存ユーザーなので false
                self.logoutMessage = "おかえり⭐︎"
                completion()
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.logoutMessage = "また後ほど♪"
            self.isLoggedIn = false
        } catch {
            print("エラー: \(error.localizedDescription)")
        }
    }
}
