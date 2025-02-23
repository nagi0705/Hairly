import SwiftUI
import FirebaseCore
import FirebaseFirestore // 🔥 Firestore のみをインポート

// Firebaseの初期化用 AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase 初期化
        FirebaseApp.configure()
        return true
    }
}

@main
struct HairlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {  // 🚀 NavigationView があることを確認！
                if authViewModel.isLoggedIn {
                    HomeView()
                } else {
                    SignUpView()
                }
            }
            .environmentObject(authViewModel)
        }
    }
}
