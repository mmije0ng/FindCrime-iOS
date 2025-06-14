import SwiftUI

struct ReportPost: Identifiable, Decodable {
    let id: Int
    let postTitle: String
    let createdAt: String

    private enum CodingKeys: String, CodingKey {
        case id = "postId"
        case postTitle
        case createdAt
    }
}

struct ReportResponse: Decodable {
    let isSuccess: Bool
    let result: ReportResult
}

struct ReportResult: Decodable {
    let postList: [ReportPost]
    let totalPage: Int
    let isFirst: Bool
    let isLast: Bool
}

struct ReportView: View {
    @State private var selectedSido: String = "서울"
    @State private var selectedGugun: String = "성북구"
    @State private var selectedCrimeType: String = "지능범죄"
    @State private var selectedCrimeDetailType: String = "사기"

    @State private var posts: [ReportPost] = []
    @State private var currentPage: Int = 1
    @State private var totalPages: Int = 1

    let maxVisiblePages = 10

    var body: some View {
        VStack(spacing: 0) {
            Text("지역 제보 조회")
                .font(.title2.bold())
                .padding(.vertical)

            ScrollView {
                VStack(spacing: 16) {
                    categorySelectors

                    tableHeader

                    ForEach(posts) { post in
                        tableRow(post: post)
                        Divider()
                    }

                    paginationControls
                }
                .padding()
            }
            .onAppear {
                fetchCrimeStats()
            }
        }
    }

    var categorySelectors: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                LabeledPicker(title: "시·도", selection: $selectedSido, options: Array(categoryData.areaMap.keys).sorted())
                    .onChange(of: selectedSido) {
                        selectedGugun = categoryData.areaMap[selectedSido]?.first ?? ""
                        fetchCrimeStats()
                    }
                LabeledPicker(title: "구·군", selection: $selectedGugun, options: categoryData.areaMap[selectedSido] ?? [])
                    .onChange(of: selectedGugun) {
                        fetchCrimeStats()
                    }
            }

            HStack(spacing: 12) {
                LabeledPicker(title: "범죄 종류", selection: $selectedCrimeType, options: Array(categoryData.crimeTypeMap.keys).sorted())
                    .onChange(of: selectedCrimeType) {
                        selectedCrimeDetailType = categoryData.crimeTypeMap[selectedCrimeType]?.first ?? ""
                        fetchCrimeStats()
                    }
                LabeledPicker(title: "범죄 세부", selection: $selectedCrimeDetailType, options: categoryData.crimeTypeMap[selectedCrimeType] ?? [])
                    .onChange(of: selectedCrimeDetailType) {
                        fetchCrimeStats()
                    }
            }
        }
    }

    var tableHeader: some View {
        HStack {
            Text("제목")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            Text("작성일")
                .fontWeight(.semibold)
                .frame(width: 120)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    func tableRow(post: ReportPost) -> some View {
        HStack {
            Text(post.postTitle.count > 10 ? String(post.postTitle.prefix(10)) + "..." : post.postTitle)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            Text(formatDate(post.createdAt))
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 120)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 4)
    }

    var paginationControls: some View {
        let startPage = max(1, min(currentPage - maxVisiblePages / 2, max(1, totalPages - maxVisiblePages + 1)))
        let endPage = min(totalPages, startPage + maxVisiblePages - 1)

        return HStack(spacing: 8) {
            if currentPage > 1 {
                Button(action: {
                    currentPage = max(1, currentPage - 1)
                    fetchCrimeStats()
                }) {
                    Text("<")
                        .foregroundColor(.blue)
                }
            }

            ForEach(startPage...endPage, id: \.self) { page in
                Button(action: {
                    currentPage = page
                    fetchCrimeStats()
                }) {
                    Text("\(page)")
                        .padding(6)
                        .frame(minWidth: 30)
                        .background(currentPage == page ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(currentPage == page ? .white : .black)
                        .cornerRadius(6)
                }
            }

            if currentPage < totalPages {
                Button(action: {
                    currentPage = min(totalPages, currentPage + 1)
                    fetchCrimeStats()
                }) {
                    Text(">")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.top, 10)
    }

    func fetchCrimeStats() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:8080"

        var components = URLComponents(string: baseURL + "/api/post")!
        components.queryItems = [
            URLQueryItem(name: "memberId", value: String(userId)),
            URLQueryItem(name: "areaName", value: selectedSido),
            URLQueryItem(name: "areaDetailName", value: selectedGugun),
            URLQueryItem(name: "crimeType", value: selectedCrimeType),
            URLQueryItem(name: "crimeDetailType", value: selectedCrimeDetailType),
            URLQueryItem(name: "page", value: String(currentPage))
        ]

        guard let url = components.url else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(ReportResponse.self, from: data)
                    DispatchQueue.main.async {
                        posts = decoded.result.postList
                        totalPages = decoded.result.totalPage
                    }
                    
                    
                } catch {
                    print("❌ 디코딩 실패: \(error)")
                }
            } else if let error = error {
                print("❌ 요청 실패: \(error.localizedDescription)")
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
