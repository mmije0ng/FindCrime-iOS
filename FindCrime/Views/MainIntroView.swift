import SwiftUI
import KakaoSDKUser

struct MainIntroView: View {
    @AppStorage("userId") var userId: Int?
    @EnvironmentObject var authManager: AuthManager // ✅ 로그인 상태 관리 객체

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Find Crime")
                .font(.largeTitle.bold())
                .foregroundColor(.blue)

//            Image(systemName: "map.fill")
            Image("lights")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)

            Text("우리 지역의 범죄 통계와\n가까운 경찰서를 지도에서 찾아보세요.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Spacer()

            // ✅ 카카오 로그인 버튼
            Button(action: startKakaoLogin) {
                HStack {
                    Spacer()
                    Image("kakao_icon")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("카카오로 로그인")
                    Spacer()
                }
                .padding()
                .background(Color(red: 254/255, green: 229/255, blue: 0))
                .foregroundColor(.black)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .padding()
    }

    /// ✅ 카카오 로그인 실행
    func startKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print("❌ KakaoTalk 로그인 실패: \(error)")
                } else if let token = oauthToken {
                    print("✅ KakaoTalk 로그인 성공. accessToken: \(token.accessToken)")
                    loginToBackend(with: token.accessToken)
                }
            }
        } else {
            // 웹 브라우저로 로그인
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    print("❌ 카카오계정 로그인 실패: \(error)")
                } else if let token = oauthToken {
                    print("✅ 카카오계정 로그인 성공. accessToken: \(token.accessToken)")
                    loginToBackend(with: token.accessToken)
                }
            }
        }
    }

    /// ✅ 백엔드에 카카오 로그인 accessToken 전달
    func loginToBackend(with accessToken: String) {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:8080"
        guard let url = URL(string: baseURL + "/api/auth/login/kakao") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                if let raw = String(data: data, encoding: .utf8) {
                    print("📦 백엔드 응답 원문: \(raw)")
                }

                if let response = try? JSONDecoder().decode(KakaoLoginResponse.self, from: data) {
                    DispatchQueue.main.async {
                        // ✅ 로그인 성공 → userId 저장 + 로그인 상태 전환
                        self.userId = response.result.userId
                        self.authManager.isLoggedIn = true
                    }
                } else {
                    print("❌ 백엔드 응답 파싱 실패 (디코딩 실패)")
                }
            } else if let error = error {
                print("❌ 네트워크 오류: \(error)")
            }
        }.resume()
    }
}

// MARK: - 백엔드 응답 모델
struct KakaoLoginResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: KakaoLoginResult
}

struct KakaoLoginResult: Decodable {
    let userId: Int
}
