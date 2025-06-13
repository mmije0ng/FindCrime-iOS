import Foundation
import Alamofire
import CoreLocation

class KakaoMapService {
    private let kakaoAPIKey = "KakaoAK \(Bundle.main.infoDictionary?["KAKAO_API_KEY"] as? String ?? "")"

    func searchPoliceStations(near coordinate: CLLocationCoordinate2D, completion: @escaping ([Place]) -> Void) {
        let url = "https://dapi.kakao.com/v2/local/search/keyword.json"
        let keyword = "경찰서 파출소 경찰청"

        let parameters: [String: Any] = [
            "query": keyword,
            "x": coordinate.longitude,
            "y": coordinate.latitude,
            "radius": 5000,
            "sort": "distance"
        ]

        let headers: HTTPHeaders = [
            "Authorization": kakaoAPIKey
        ]

        AF.request(url, parameters: parameters, headers: headers).responseDecodable(of: KakaoSearchResponse.self) { response in
            switch response.result {
            case .success(let result):
                completion(result.documents)
            case .failure(let error):
                print("Kakao API 오류: \(error.localizedDescription)")
                if let data = response.data, let raw = String(data: data, encoding: .utf8) {
                    print("원본 응답:", raw)
                }
                completion([])
            }
        }
    }
}
