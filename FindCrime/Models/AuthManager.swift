//
//  AuthManager.swift
//  FindCrime
//
//  Created by 박미정 on 6/15/25.
//

import Foundation
import SwiftUI // ✅ 중요!

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = UserDefaults.standard.integer(forKey: "userId") != 0

    func logout() {
        UserDefaults.standard.removeObject(forKey: "userId")
        isLoggedIn = false
    }
}
