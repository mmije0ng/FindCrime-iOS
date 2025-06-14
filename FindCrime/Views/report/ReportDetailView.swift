import SwiftUI

struct ReportDetailResponse: Decodable {
    let isSuccess: Bool
    let result: ReportDetail
}

struct ReportDetail: Decodable {
    let postTitle: String
    let postContent: String
    let nickName: String
    let profileImageUrl: String?
    let createdAt: String
    var isLiked: Bool
}

struct ReportDetailView: View {
    let postId: Int
    @State private var detail: ReportDetail? = nil

    var body: some View {
        VStack {
            if let detail = detail {
                VStack(spacing: 16) {
                    HStack {
                        if let urlString = detail.profileImageUrl,
                           let url = URL(string: urlString),
                           url.scheme == "http" || url.scheme == "https" {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else if phase.error != nil {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .foregroundColor(.gray)
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }

                        VStack(alignment: .leading) {
                            Text(detail.nickName)
                                .font(.headline)
                            Text(formatDate(detail.createdAt))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button(action: {
                            toggleLike()
                        }) {
                            Image(systemName: detail.isLiked ? "heart.fill" : "heart")
                                .foregroundColor(detail.isLiked ? .red : .gray)
                        }
                    }

                    Text(detail.postTitle)
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(detail.postContent)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                }
                .padding()
            } else {
                ProgressView("불러오는 중...")
                    .onAppear(perform: fetchDetail)
            }
        }
        .navigationTitle("제보 상세")
        .navigationBarTitleDisplayMode(.inline)
    }

    func fetchDetail() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:8080"
        let urlString = "\(baseURL)/api/post/\(postId)?memberId=\(userId)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(ReportDetailResponse.self, from: data)
                    DispatchQueue.main.async {
                        detail = decoded.result
                    }
                } catch {
                    print("❌ 디코딩 실패: \(error)")
                }
            } else if let error = error {
                print("❌ 요청 실패: \(error.localizedDescription)")
            }
        }.resume()
    }

    func toggleLike() {
        guard var currentDetail = detail else { return }
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:8080"
        let action = currentDetail.isLiked ? "DELETE" : "POST"
        let urlString = "\(baseURL)/api/post/like/\(userId)/\(postId)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = action

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ 좋아요 요청 실패: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                currentDetail.isLiked.toggle()
                detail = currentDetail
            }
        }.resume()
    }

    func formatDate(_ isoDate: String) -> String {
        let trimmed = isoDate.trimmingCharacters(in: .whitespacesAndNewlines)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        if let date = formatter.date(from: trimmed) {
            let display = DateFormatter()
            display.locale = Locale(identifier: "ko_KR")
            display.dateFormat = "yyyy.MM.dd HH:mm"
            return display.string(from: date)
        } else {
            print("❌ 날짜 파싱 실패: \(trimmed)")
            return trimmed
        }
    }
}
