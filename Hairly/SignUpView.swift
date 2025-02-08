import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Hairly")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)

            // 🔥 ログアウト後のメッセージを表示
            if !authViewModel.logoutMessage.isEmpty {
                Text(authViewModel.logoutMessage)
                    .foregroundColor(.red)
                    .bold()
                    .padding()
            }

            TextField("メールアドレス", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)

            SecureField("パスワード", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: signUp) {
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

            Button(action: login) {
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

            Spacer()
        }
        .padding()
    }

    func signUp() {
        authViewModel.signUp(email: email, password: password) {}
    }

    func login() {
        authViewModel.login(email: email, password: password) {}
    }
}

#Preview {
    SignUpView().environmentObject(AuthViewModel())
}
