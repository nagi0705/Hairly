import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil  // 🔥 初期値を現在のログイン状態に設定

    init() {
        checkLoginStatus()
    }

    func checkLoginStatus() {
        isLoggedIn = Auth.auth().currentUser != nil
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false  // 🔥 ログアウト後、SignUpViewに戻る
        } catch {
            print("エラー: \(error.localizedDescription)")
        }
    }
}
