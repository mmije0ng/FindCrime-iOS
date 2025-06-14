import SwiftUI
import KakaoSDKCommon
@main
struct FindCrimeApp: App {
    @StateObject var authManager = AuthManager()

    // ✅ AppDelegate 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                ContentView()
                    .environmentObject(authManager)
            } else {
                MainIntroView()
                    .environmentObject(authManager)
            }
        }
    }
}

