//
//  FindCrimeApp.swift
//  FindCrime
//
//  Created by 박미정 on 6/13/25.
//

//import SwiftUI
//
//@main
//struct FindCrimeApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

import SwiftUI
import KakaoSDKCommon

@main
struct FindCrimeApp: App {
    
    // ✅ AppDelegate 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
