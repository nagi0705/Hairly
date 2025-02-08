import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel  // 🔥 AuthViewModel を利用

    var body: some View {
        VStack(spacing: 20) {
            Text("ホーム画面")
                .font(.largeTitle)
                .bold()

            // 現在ログイン中のユーザーのメールアドレスを表示
            if let user = Auth.auth().currentUser {
                Text("ログイン中: \(user.email ?? "不明なユーザー")")
                    .font(.title3)
                    .foregroundColor(.gray)
            }

            Button(action: authViewModel.signOut) {  // 🔥 ログアウト処理をAuthViewModelに移動
                Text("ログアウト")
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    HomeView().environmentObject(AuthViewModel())  // 🔥 environmentObject を追加
}
