import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var authViewModel: AuthViewModel  // 🔥 修正: メッセージをグローバルに管理

    var body: some View {
        VStack(spacing: 20) {
            Text("Hairly")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)

            TextField("メールアドレス", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)

            SecureField("パスワード", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: { authViewModel.signUp(email: email, password: password) }) {
                Text("サインアップ")
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Button(action: { authViewModel.login(email: email, password: password) }) {
                Text("ログイン")
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Text(authViewModel.message)  // 🔥 修正: グローバルのメッセージを表示
                .foregroundColor(.red)
                .bold()
                .padding()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    SignUpView().environmentObject(AuthViewModel())
}
