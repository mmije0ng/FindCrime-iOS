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
                .edgesIgnoringSafeArea(.all)

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
                Text("위치를 불러오는 중입니다...")
            }
        }
        .onAppear {
            locationManager.onInitialLocationFix = { location in
                print("📍 앱 시작 시 위치 고정: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                KakaoMapService().searchPoliceStations(near: location.coordinate) { fetched in
                    DispatchQueue.main.async {
                        self.places = Array(fetched.prefix(10))
                    }
                }
            }
        }
    }
}
