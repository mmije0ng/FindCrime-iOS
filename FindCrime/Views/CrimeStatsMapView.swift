import SwiftUI
import MapKit
import CoreLocation

struct CrimeStatsMapView: View {
    @State private var selectedSido: String = "경기도"
    @State private var selectedGugun: String = "수원시"
    @State private var selectedYear: String = "2023"
    @State private var selectedCrimeType: String = "지능범죄"
    @State private var selectedCrimeDetailType: String = "사기"

    @State private var crimeCount: Int?
    @State private var crimeRisk: String?
    @State private var location: CLLocationCoordinate2D? = nil

    let sidos = ["서울", "경기도"]
    let guguns = ["성북구", "수원시", "경기도전체"]
    let years = ["2023"]
    let crimeTypes = ["강력범죄", "지능범죄"]
    let crimeDetailTypes = ["살인기수", "강도", "사기"]

    var body: some View {
        VStack(spacing: 0) {
            Text("우리 지역 범죄 통계 조회")
                .font(.title2.bold())
                .padding(.vertical)

            ScrollView {
                VStack(spacing: 16) {
                    // 연도 단독 Picker
                    LabeledPicker(title: "연도", selection: $selectedYear, options: years)

                    // 시/도 + 구/군 가로 배치
                    HStack(spacing: 12) {
                        LabeledPicker(title: "시·도", selection: $selectedSido, options: sidos)
                        LabeledPicker(title: "구·군", selection: $selectedGugun, options: guguns)
                    }

                    // 범죄 유형 + 상세 유형 가로 배치
                    HStack(spacing: 12) {
                        LabeledPicker(title: "범죄 종류", selection: $selectedCrimeType, options: crimeTypes)
                        LabeledPicker(title: "범죄 세부", selection: $selectedCrimeDetailType, options: crimeDetailTypes)
                    }

                    Button(action: fetchCrimeStats) {
                        Text("통계 조회")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            }

            // 지도 화면
            MapViewRepresentable(location: location, crimeCount: crimeCount, crimeRisk: crimeRisk)
                .frame(minHeight: 470, maxHeight: .infinity)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
    }

    func fetchCrimeStats() {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:8080"
        let urlStr = "\(baseURL)/api/statistics?year=\(selectedYear)&areaName=\(selectedSido)&areaDetailName=\(selectedGugun)&crimeType=\(selectedCrimeType)&crimeDetailType=\(selectedCrimeDetailType)"

        guard let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(CrimeStatsResponse.self, from: data) else { return }

            CLGeocoder().geocodeAddressString("\(selectedSido) \(selectedGugun)") { placemarks, _ in
                DispatchQueue.main.async {
                    self.crimeCount = decoded.result.crimeCount
                    self.crimeRisk = decoded.result.crimeRisk
                    if let coordinate = placemarks?.first?.location?.coordinate {
                        self.location = coordinate
                    }
                }
            }
        }.resume()
    }
}

struct LabeledPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Picker(selection: $selection, label: Text("")) {
                ForEach(options, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
