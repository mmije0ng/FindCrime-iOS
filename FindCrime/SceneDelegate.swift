import UIKit
import SwiftUI
import KakaoSDKAuth // ✅ Kakao 인증 모듈 임포트
import KakaoSDKCommon // ✅ Kakao SDK 초기화용

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // ✅ Kakao SDK를 위한 URL 처리
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            // 카카오 로그인 리디렉션 처리
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }

    // 기존 연결 로직
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        // ✅ SwiftUI View를 루트로 설정하는 경우 예시
        let contentView = MainIntroView(isLoggedIn: .constant(false))
        window.rootViewController = UIHostingController(rootView: contentView)

        self.window = window
        window.makeKeyAndVisible()
    }
}
