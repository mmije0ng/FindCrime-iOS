import SwiftUI
import KakaoSDKUser

struct MainIntroView: View {
    @Binding var isLoggedIn: Bool
    @AppStorage("userId") var userId: Int?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("FindCrime")
                .font(.largeTitle.bold())
                .foregroundColor(.blue)

            Image(systemName: "map.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)

            Text("우리 지역의 범죄 통계와\n가까운 경찰서를 지도에서 찾아보세요.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Spacer()

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
            // 카카오계정으로 로그인 (웹)
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

    func loginToBackend(with accessToken: String) {
        guard let url = URL(string: "http://localhost:8080/api/auth/login/kakao") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // ✅ Authorization 헤더에 accessToken 추가
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                if let raw = String(data: data, encoding: .utf8) {
                    print("📦 백엔드 응답 원문: \(raw)")
                }

                if let response = try? JSONDecoder().decode(KakaoLoginResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.userId = response.result.userId
                        self.isLoggedIn = true
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

struct KakaoLoginResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: KakaoLoginResult
}

struct KakaoLoginResult: Decodable {
    let userId: Int
}
