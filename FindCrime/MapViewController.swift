import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    let kakaoService = KakaoMapService()
    var isFirstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocation()
    }

    func setupMapView() {
        mapView.frame = view.bounds
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        view.addSubview(mapView)
    }

    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationManager.stopUpdatingLocation()

        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapView.setRegion(region, animated: true)

        fetchPoliceStations(at: location.coordinate)
    }

    func fetchPoliceStations(at coordinate: CLLocationCoordinate2D) {
        kakaoService.searchPoliceStations(near: coordinate) { [weak self] places in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)

                for place in places {
                    guard let lat = Double(place.y), let lon = Double(place.x) else { continue }

                    let annotation = PlaceAnnotation(place: place,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }

    // ✅ 마커 뷰 생성 및 스타일 적용
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PlaceAnnotation else { return nil }

        let identifier = "PoliceMarker"
        var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if markerView == nil {
            markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            markerView?.annotation = annotation
        }

        // ⭐️ 매번 스타일을 확실히 다시 입힘
        markerView?.glyphImage = UIImage(systemName: "shield.fill")
        markerView?.markerTintColor = .systemRed
        markerView?.titleVisibility = .visible
        markerView?.subtitleVisibility = .hidden
        markerView?.canShowCallout = false

        return markerView
    }

    // ✅ 지도 이동 감지 → 마커 갱신
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        fetchPoliceStations(at: center)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 에러: \(error.localizedDescription)")
    }
}
