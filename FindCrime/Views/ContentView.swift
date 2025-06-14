//import SwiftUI
//
//struct ContentView: View {
//    @State private var isLoggedIn = false
//
//    var body: some View {
//        if isLoggedIn {
//            MainTabView()
//        } else {
//            MainIntroView(isLoggedIn: $isLoggedIn)
//        }
//    }
//}

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
