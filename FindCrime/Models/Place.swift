import Foundation

struct KakaoSearchResponse: Codable {
    let documents: [Place]
}

struct Place: Identifiable, Codable, Hashable {
    let placeName: String
    let roadAddressName: String?
    let x: String
    let y: String

    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case roadAddressName = "road_address_name"
        case x, y
    }

    // ✅ x+y 기반 고유 id 생성
    var id: String {
        "\(x)-\(y)"
    }
}
