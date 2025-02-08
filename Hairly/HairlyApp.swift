import SwiftUI
import FirebaseCore

// Firebaseの初期化用 AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct HairlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()  // 🔥 追加

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if authViewModel.isLoggedIn {
                    HomeView()
                } else {
                    SignUpView()
                }
            }
            .environmentObject(authViewModel)  // 🔥 追加
        }
    }
}
