
import SwiftUI
import MapKit
import CoreLocation

let categoryData = CategoryData.load()

struct CrimeStatsMapView: View {
    @State private var selectedSido: String = "전국"
    @State private var selectedGugun: String = "전국전체"
    @State private var selectedCrimeType: String = ""
    @State private var selectedCrimeDetailType: String = ""
    @State private var selectedYear: String = "2023"

    @State private var crimeCount: Int?
    @State private var crimeRisk: String?
    @State private var region: MKCoordinateRegion = regionCoordinates["전국"]!
    @State private var markerCoordinate: CLLocationCoordinate2D? = nil

    var body: some View {
        VStack(spacing: 0) {
            Text("우리 지역 범죄 통계 조회")
                .font(.title2.bold())
                .padding(.vertical)

            ScrollView {
                VStack(spacing: 16) {
                    LabeledPicker(title: "연도", selection: $selectedYear, options: ["2023"])

                    HStack(spacing: 12) {
                        LabeledPicker(title: "시·도", selection: $selectedSido, options: Array(categoryData.areaMap.keys).sorted())
                            .onChange(of: selectedSido) {
                                selectedGugun = categoryData.areaMap[selectedSido]?.first ?? ""
                            }

                        LabeledPicker(title: "구·군", selection: $selectedGugun, options: categoryData.areaMap[selectedSido] ?? [])
                    }

                    HStack(spacing: 12) {
                        LabeledPicker(title: "범죄 종류", selection: $selectedCrimeType, options: Array(categoryData.crimeTypeMap.keys).sorted())
                            .onChange(of: selectedCrimeType) {
                                selectedCrimeDetailType = categoryData.crimeTypeMap[selectedCrimeType]?.first ?? ""
                            }

                        LabeledPicker(title: "범죄 세부", selection: $selectedCrimeDetailType, options: categoryData.crimeTypeMap[selectedCrimeType] ?? [])
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

            MapViewRepresentable(location: markerCoordinate, crimeCount: crimeCount, crimeRisk: crimeRisk, region: $region)
                .frame(minHeight: 380, maxHeight: .infinity)
        }
        .onAppear {
            if selectedCrimeType.isEmpty {
                selectedCrimeType = Array(categoryData.crimeTypeMap.keys).sorted().first ?? ""
                selectedCrimeDetailType = categoryData.crimeTypeMap[selectedCrimeType]?.first ?? ""
            }
        }
    }

    func fetchCrimeStats() {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:8080"
        let urlStr = "\(baseURL)/api/statistics?year=\(selectedYear)&areaName=\(selectedSido)&areaDetailName=\(selectedGugun)&crimeType=\(selectedCrimeType)&crimeDetailType=\(selectedCrimeDetailType)"

        guard let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(CrimeStatsResponse.self, from: data) else { return }

            DispatchQueue.main.async {
                self.crimeCount = decoded.result.crimeCount
                self.crimeRisk = decoded.result.crimeRisk
                self.updateRegionAndMarker()
            }
        }.resume()
    }

    func updateRegionAndMarker() {
        let combined = "\(selectedSido)\(selectedGugun)"

        if selectedGugun == "전국전체" {
            print("전국전체")
            region = regionCoordinates["전국"]!  // ✅ 지도도 다시 설정
            markerCoordinate = CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5)
            return
        }

        if selectedGugun.contains("전체"), let coord = regionCenterCoordinates[selectedSido] {
            region = regionCoordinates["전국"]!
            markerCoordinate = coord
        } else {
            let address = "\(selectedSido) \(selectedGugun)"
            CLGeocoder().geocodeAddressString(address) { placemarks, _ in
                if let coordinate = placemarks?.first?.location?.coordinate {
                    region = MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    )
                    markerCoordinate = coordinate
                }
            }
        }
    }
    
    func isShowingNationwideCenter(coordinate: CLLocationCoordinate2D) -> Bool {
        // 중심값 근처 좌표인지 확인 (대한민국 중심 좌표)
        let center = CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5)
        let threshold = 0.01
        return abs(coordinate.latitude - center.latitude) < threshold &&
               abs(coordinate.longitude - center.longitude) < threshold
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

let regionCoordinates: [String: MKCoordinateRegion] = [
    "전국": MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.5, longitude: 127.8),
        span: MKCoordinateSpan(latitudeDelta: 6.5, longitudeDelta: 6.5)
    ),
//    "서울": MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
//        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
//    )
//    // 필요시 추가
]

let regionCenterCoordinates: [String: CLLocationCoordinate2D] = [
    "전국": CLLocationCoordinate2D(latitude: 36.5, longitude: 127.8),
//    "서울": CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
//    "경기도": CLLocationCoordinate2D(latitude: 37.4138, longitude: 127.5183),
//    "부산": CLLocationCoordinate2D(latitude: 35.1796, longitude: 129.0756),
    // 필요한 시도는 추가
]
