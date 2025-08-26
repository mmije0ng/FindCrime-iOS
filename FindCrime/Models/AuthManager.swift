//
//  AuthManager.swift
//  FindCrime
//
//  Created by 박미정 on 6/15/25.
//

import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    // 로그인 상태: userId가 저장돼 있으면 true
    @Published var isLoggedIn: Bool = UserDefaults.standard.integer(forKey: "userId") != 0

    /// 로그아웃 처리
    func logout() {
        // 저장된 사용자 정보 및 토큰 삭제
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")

        // 상태 갱신
        DispatchQueue.main.async {
            self.isLoggedIn = false
        }

        print("✅ 로그아웃 완료: userId, accessToken, refreshToken 삭제됨")
    }
}
