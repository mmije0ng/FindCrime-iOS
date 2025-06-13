import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    var onInitialLocationFix: ((CLLocation) -> Void)?  // ✅ 콜백 추가

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }

        if lastLocation == nil {
            onInitialLocationFix?(latest)  // ✅ 최초 위치일 때만 호출
        }

        lastLocation = latest
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 위치 오류: \(error.localizedDescription)")
    }
}
