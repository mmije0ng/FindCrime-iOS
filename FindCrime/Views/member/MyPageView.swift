import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var user: MyPageUser? = nil

    var body: some View {
        ZStack {
            // 🔹 전체 배경 파란색
            Color(red: 210/255, green: 230/255, blue: 255/255)
                .ignoresSafeArea()

            VStack {
                if let user = user {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 40)

                        if let url = URL(string: user.profileImageUrl ?? "") {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fill)
                                case .failure:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                                .shadow(radius: 5)
                        }

                        Text(user.nickName)
                            .font(.title2.bold())
                            .foregroundColor(.black)

                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text("가입일: \(formatDate(user.createdAt))")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        Spacer()

                        // ✅ 로그아웃 버튼을 내부에 포함
                        Button(action: {
                            authManager.logout()
                        }) {
                            Text("로그아웃")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.1), radius: 10, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 24)

                    Spacer()
                } else {
                    ProgressView("사용자 정보를 불러오는 중...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.top, 100)
                }
            }
        }
        .onAppear(perform: fetchUserInfo)
    }

    func fetchUserInfo() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:8080"
        guard let url = URL(string: "\(baseURL)/api/member/\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(MyPageResponse.self, from: data) {
                    DispatchQueue.main.async {
                        user = decoded.result
                    }
                }
            }
        }.resume()
    }

    func formatDate(_ isoDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter.date(from: isoDate) {
            let output = DateFormatter()
            output.dateFormat = "yyyy.MM.dd HH:mm"
            output.locale = Locale(identifier: "ko_KR")
            return output.string(from: date)
        }
        return isoDate
    }
}

struct MyPageResponse: Decodable {
    let isSuccess: Bool
    let result: MyPageUser
}

struct MyPageUser: Decodable {
    let email: String
    let nickName: String
    let profileImageUrl: String?
    let createdAt: String
}
