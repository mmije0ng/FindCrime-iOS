import SwiftUI
import KakaoSDKUser

struct MainIntroView: View {
    @AppStorage("userId") var userId: Int?
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Find Crime")
                .font(.largeTitle.bold())
                .foregroundColor(.blue)
            
            Image("lights")
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
    
    // ✅ 카카오 로그인 실행
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
    
    // ✅ 백엔드 로그인 요청
    func loginToBackend(with kakaoAccessToken: String) {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:8080"
        guard let url = URL(string: baseURL + "/api/auth/login/kakao") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // ✅ 헤더를 통째로 설정 (Authorization 강제 적용)
        request.setValue("Bearer \(kakaoAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // ✅ 요청 직전 최종 request 로그 출력
        print("📌 최종 요청 URL: \(url.absoluteString)")
        print("📌 최종 요청 객체: \(request)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📌 서버 응답 코드: \(httpResponse.statusCode)")
                
                if let accessToken = httpResponse.allHeaderFields["Authorization"] as? String {
                    let rawAccess = accessToken.replacingOccurrences(of: "Bearer ", with: "")
                    UserDefaults.standard.set(rawAccess, forKey: "accessToken")
                    print("✅ 서버 JWT AccessToken 저장 완료: \(rawAccess)")
                }

                if let refreshToken = httpResponse.allHeaderFields["Refresh-Token"] as? String {
                    UserDefaults.standard.set(refreshToken, forKey: "refreshToken") // 그대로 저장
                }
            }
            
            if let error = error {
                print("❌ 네트워크 오류: \(error)")
                return
            }
            
            if let data = data, let raw = String(data: data, encoding: .utf8) {
                print("📦 백엔드 응답 원문: \(raw)")
            }
            
            DispatchQueue.main.async {
                self.authManager.isLoggedIn = true
            }
        }.resume()
    }
}
