import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var user: MyPageUser? = nil

    var body: some View {
        VStack {
            if let user = user {
                VStack(spacing: 12) {
                    if let url = URL(string: user.profileImageUrl ?? "") {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty: ProgressView()
                            case .success(let image): image.resizable().aspectRatio(contentMode: .fill)
                            case .failure: Image(systemName: "person.crop.circle.fill").resizable()
                            @unknown default: EmptyView()
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }

                    Text(user.nickName).font(.title3.bold())
                    Text(user.email).font(.subheadline).foregroundColor(.gray)
                    Text("가입일: \(formatDate(user.createdAt))").font(.caption).foregroundColor(.gray)
                }
                .padding(.top, 40)

                Spacer()

                Button(action: {
                    authManager.logout()
                }) {
                    Text("로그아웃")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding()
            } else {
                ProgressView("불러오는 중...").onAppear(perform: fetchUserInfo)
            }
        }
        .padding()
    }

    func fetchUserInfo() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        guard let url = URL(string: "http://localhost:8080/api/member/\(userId)") else { return }

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
