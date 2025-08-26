//
//  NetworkManager.swift
//  FindCrime
//
//  Created by 박미정 on 8/26/25.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - 공통 요청 (401/403 → 토큰 재발급 후 재시도)
    func requestWithAuthRetry(_ request: URLRequest,
                              completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse,
               (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
                print("⚠️ AccessToken 만료 → 토큰 재발급 시도")
                self.regenerateTokens { success in
                    if success {
                        print("✅ 토큰 재발급 성공 → 원래 요청 재시도")
                        var retryRequest = request
                        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
                            retryRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        }
                        self.session.dataTask(with: retryRequest, completionHandler: completion).resume()
                    } else {
                        print("❌ 토큰 재발급 실패")
                        completion(data, response, error)
                    }
                }
            } else {
                completion(data, response, error)
            }
        }.resume()
    }
    
    // MARK: - 토큰 재발급 API 호출
    private func regenerateTokens(completion: @escaping (Bool) -> Void) {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
            completion(false)
            return
        }
        
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:8080"
        guard let url = URL(string: baseURL + "/api/auth/regenerate") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(refreshToken, forHTTPHeaderField: "Refresh-Token") // RefreshToken은 prefix 없음
        
        session.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                // ✅ 토큰 저장 시 Bearer prefix 제거
                if let newAccess = httpResponse.value(forHTTPHeaderField: "Authorization") {
                    let cleanAccess = newAccess.replacingOccurrences(of: "Bearer ", with: "")
                    UserDefaults.standard.set(cleanAccess, forKey: "accessToken")
                    print("🔄 새 AccessToken 저장: \(cleanAccess)")
                }
                if let newRefresh = httpResponse.value(forHTTPHeaderField: "Refresh-Token") {
                    UserDefaults.standard.set(newRefresh, forKey: "refreshToken")
                    print("🔄 새 RefreshToken 저장: \(newRefresh)")
                }
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
}

// MARK: - POST 요청
extension NetworkManager {
    func post(_ url: URL, body: [String: Any], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ✅ Bearer prefix 자동 부착
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        if let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") {
            request.setValue(refreshToken, forHTTPHeaderField: "Refresh-Token")
        }

        // Body 직렬화
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ Body 직렬화 실패: \(error)")
            completion(nil, nil, error)
            return
        }

        // 로그
        print("📌 POST 요청 URL:", url.absoluteString)
        print("📌 POST 요청 헤더:", request.allHTTPHeaderFields ?? [:])
        print("📌 POST 요청 Body:", body)

        session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📌 응답 코드:", httpResponse.statusCode)
                print("📌 응답 헤더:", httpResponse.allHeaderFields)
                if let newAccess = httpResponse.value(forHTTPHeaderField: "Authorization") {
                    let cleanAccess = newAccess.replacingOccurrences(of: "Bearer ", with: "")
                    UserDefaults.standard.setValue(cleanAccess, forKey: "accessToken")
                }
                if let newRefresh = httpResponse.value(forHTTPHeaderField: "Refresh-Token") {
                    UserDefaults.standard.setValue(newRefresh, forKey: "refreshToken")
                }
            }
            completion(data, response, error)
        }.resume()
    }
}

// MARK: - GET/공통 요청
extension NetworkManager {
    func request(_ url: URL,
                 method: String = "GET",
                 completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // ✅ JWT 자동 포함
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        if let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") {
            request.setValue(refreshToken, forHTTPHeaderField: "Refresh-Token")
        }

        requestWithAuthRetry(request, completion: completion)
    }
}
