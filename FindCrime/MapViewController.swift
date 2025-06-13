import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    let mapView = MKMapView()
    let kakaoService = KakaoMapService()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        setupLocation()
    }

    func setupMapView() {
        mapView.frame = view.bounds
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        view.addSubview(mapView)
    }

    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationManager.stopUpdatingLocation()

        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 3000,
                                        longitudinalMeters: 3000)
        mapView.setRegion(region, animated: true)

        // Kakao REST API로 주변 경찰서 검색
        kakaoService.searchPoliceStations(near: location.coordinate) { [weak self] places in
            guard let self = self else { return }

            for place in places {
                self.addMarker(for: place)
            }
        }
    }

    func addMarker(for place: Place) {
        guard let latitude = Double(place.y), let longitude = Double(place.x) else { return }

        let annotation = MKPointAnnotation()
        annotation.title = place.placeName
        annotation.subtitle = place.roadAddressName
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        mapView.addAnnotation(annotation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 오류: \(error.localizedDescription)")
    }
}

