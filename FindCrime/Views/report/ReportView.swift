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
    @State private var showCreateSheet: Bool = false
    @State private var selectedPostId: Int? = nil

    let maxVisiblePages = 10

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 210/255, green: 230/255, blue: 255/255)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("지역 사건 제보")
                            .font(.title2.bold())
                        Spacer()
                        Button(action: {
                            showCreateSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .padding(5)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                    .padding()

                    ScrollView {
                        VStack(spacing: 25) {
                            categorySelectors
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                                .padding(.horizontal)

//                            tableHeader
//                                .background(Color(.systemGray5))
//                                .cornerRadius(8)

                            VStack(spacing: 0) {
                                ForEach(posts) { post in
                                    NavigationLink(destination: ReportDetailView(postId: post.id)) {
                                        tableRow(post: post)
                                    }
                                    Divider()
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)

                            paginationControls
                        }
                        .padding()
                    }
                    .sheet(isPresented: $showCreateSheet, onDismiss: {
                        currentPage = 1
                        fetchCrimeStats()
                    }) {
                        ReportCreateView()
                    }
                }
            }
        }
        .onAppear {
            fetchCrimeStats()
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
    
//    var tableHeader: some View {
//        HStack {
//            Text("제목")
//                .font(.subheadline)
//                .fontWeight(.medium)
//                .foregroundColor(.gray)
//                .frame(maxWidth: .infinity)
//                .multilineTextAlignment(.center)
//
//            Text("작성일")
//                .font(.subheadline)
//                .fontWeight(.medium)
//                .foregroundColor(.gray)
//                .frame(width: 120)
//                .multilineTextAlignment(.center)
//        }
//        .padding(.vertical, 10)
//        .background(Color.white)
//        .cornerRadius(10)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//        )
//        .padding(.horizontal, 4)
//    }


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
        .padding(.vertical, 6)
        .background(Color.white)
    }

    var paginationControls: some View {
        let startPage = max(1, min(currentPage - maxVisiblePages / 2, max(1, totalPages - maxVisiblePages + 1)))
        let endPage = min(totalPages, startPage + maxVisiblePages - 1)

        return HStack(spacing: 8) {
            if currentPage > 1 {
                Button(action: {
                    currentPage -= 1
                    fetchCrimeStats()
                }) {
                    Image(systemName: "chevron.left")
                        .padding(6)
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
                    currentPage += 1
                    fetchCrimeStats()
                }) {
                    Image(systemName: "chevron.right")
                        .padding(6)
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
            display.dateFormat = "yyyy.MM.dd\nHH:mm"
            return display.string(from: date)
        } else {
            print("❌ 날짜 파싱 실패: \(trimmed)")
            return trimmed
        }
    }
}
