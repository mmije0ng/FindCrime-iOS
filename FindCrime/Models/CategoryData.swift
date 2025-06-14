//
//  CategoryData.swift
//  FindCrime
//
//  Created by 박미정 on 6/14/25.
//
import Foundation

struct CategoryData: Decodable {
    let areaMap: [String: [String]]
    let crimeTypeMap: [String: [String]]
    
    static func load() -> CategoryData {
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "json") else {
            print("❌ categories.json 경로를 찾을 수 없습니다.")
            return CategoryData(areaMap: [:], crimeTypeMap: [:])
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(CategoryData.self, from: data)
            print("✅ 카테고리 로딩 성공: \(decoded.areaMap.keys.count)개 시도")
            return decoded
        } catch {
            print("❌ 카테고리 JSON 파싱 실패:", error)
            return CategoryData(areaMap: [:], crimeTypeMap: [:])
        }
    }
}

