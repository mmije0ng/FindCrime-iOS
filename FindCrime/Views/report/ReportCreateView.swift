//
//  ReportCreateView.swift
//  FindCrime
//
//  Created by 박미정 on 6/15/25.
//

import SwiftUI

struct ReportCreateView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var postTitle: String = ""
    @State private var postContent: String = ""

    @State private var areaName: String = "서울"
    @State private var areaDetailName: String = "성북구"
    @State private var crimeType: String = "지능범죄"
    @State private var crimeDetailType: String = "사기"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("제목")) {
                    TextField("제목을 입력하세요", text: $postTitle)
                }

                Section(header: Text("내용")) {
                    TextEditor(text: $postContent)
                        .frame(height: 150)
                }

                Section(header: Text("지역 정보")) {
                    Picker("시도", selection: $areaName) {
                        ForEach(Array(categoryData.areaMap.keys).sorted(), id: \.self) { Text($0) }
                    }

                    Picker("구군", selection: $areaDetailName) {
                        ForEach(categoryData.areaMap[areaName] ?? [], id: \.self) { Text($0) }
                    }
                }

                Section(header: Text("범죄 유형")) {
                    Picker("종류", selection: $crimeType) {
                        ForEach(Array(categoryData.crimeTypeMap.keys).sorted(), id: \.self) { Text($0) }
                    }

                    Picker("세부", selection: $crimeDetailType) {
                        ForEach(categoryData.crimeTypeMap[crimeType] ?? [], id: \.self) { Text($0) }
                    }
                }

                Button("제보 등록") {
                    createReportPost()
                }
            }
            .navigationTitle("제보 작성")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func createReportPost() {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://127.0.0.1:8080"
        guard let url = URL(string: "\(baseURL)/api/post") else { return }

        let body: [String: Any] = [
            "postTitle": postTitle,
            "postContent": postContent,
            "areaName": areaName,
            "areaDetailName": areaDetailName,
            "crimeType": crimeType,
            "crimeDetailType": crimeDetailType
        ]

        // ✅ NetworkManager 활용 (401/403 시 자동 재발급)
        NetworkManager.shared.post(url, body: body) { data, response, error in
            if let error = error {
                print("❌ 요청 실패:", error.localizedDescription)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("📌 응답 코드:", httpResponse.statusCode)
            }
            if let data = data, let raw = String(data: data, encoding: .utf8) {
                print("✅ 등록 응답:", raw)
            }
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

}
