import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("ホーム画面")
                .font(.largeTitle)
                .bold()

            // 📌 ログインメッセージ
            Text(authViewModel.isNewUser ? "ようこそ！" : "おかえり⭐︎")
                .foregroundColor(.blue)
                .bold()
                .padding()

            // 📌 チャット画面に移動するボタン
            NavigationLink(destination: ChatView()) {
                Text("チャットを開く")
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // 📌 ログアウトボタン
            Button(action: authViewModel.signOut) {
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

            Spacer()
        }
        .padding()
    }
}

#Preview {
    HomeView().environmentObject(AuthViewModel())
}
