import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("ホーム画面")
                .font(.largeTitle)
                .bold()

            Button(action: { authViewModel.signOut() }) {
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

            Text(authViewModel.message)  // 🔥 修正: グローバルのメッセージを表示
                .foregroundColor(.blue)
                .bold()
                .padding()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    HomeView().environmentObject(AuthViewModel())
}
