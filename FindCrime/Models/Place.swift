import Foundation

struct KakaoSearchResponse: Codable {
    let documents: [Place]
}

struct Place: Codable, Equatable {
    let placeName: String
    let roadAddressName: String?
    let distance: String?
    let x: String
    let y: String

    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case roadAddressName = "road_address_name"
        case distance, x, y
    }
}
