import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var places: [Place] = []
    @State private var selectedPlace: Place? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            if let coord = locationManager.lastLocation?.coordinate {
                MapKitView(
                    coordinate: coord,
                    places: $places,
                    selectedPlace: $selectedPlace
                )

                if let selected = selectedPlace {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selected.placeName)
                            .font(.headline)
                        Text(selected.roadAddressName ?? "주소 없음")
                            .font(.subheadline)
                        Divider()
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: selectedPlace)
                }
            } else {
                Text("위치 불러오는 중...")
            }
        }
        .onReceive(locationManager.$lastLocation) { location in
            guard let location = location else { return }

            KakaoMapService().searchPoliceStations(near: location.coordinate) { fetched in
                DispatchQueue.main.async {
                    self.places = Array(fetched.prefix(10)) // 최대 10개 제한
                }
            }
        }
    }
}
