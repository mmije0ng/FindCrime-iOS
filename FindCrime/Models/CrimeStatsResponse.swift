//
//  CrimeStatsResponse.swift
//  FindCrime
//
//  Created by 박미정 on 6/14/25.
//

// MARK: - Response
struct CrimeStatsResponse: Decodable {
    let result: CrimeStatsResult
}

struct CrimeStatsResult: Decodable {
    let crimeCount: Int
    let crimeRisk: String
}
