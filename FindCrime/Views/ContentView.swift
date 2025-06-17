import Foundation
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        if authManager.isLoggedIn {
            MainTabView()
        } else {
            MainIntroView()
        }
    }
}
