//
//  AppDelegate.swift
//  FindCrime
//
//  Created by 박미정 on 6/14/25.
//

import UIKit
import KakaoSDKCommon

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        if let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as? String {
            KakaoSDK.initSDK(appKey: kakaoAppKey)
        } else {
            print("❌ 카카오 앱 키 로딩 실패")
        }

        return true
    }
}
