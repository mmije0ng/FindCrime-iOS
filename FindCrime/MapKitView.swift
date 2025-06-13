import SwiftUI
import MapKit
import CoreLocation

struct MapKitView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    @Binding var places: [Place]
    @Binding var selectedPlace: Place?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(
            MKCoordinateRegion(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000),
            animated: false
        )
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)

        var annotations: [MKAnnotation] = []

        for place in places {
            guard let lat = Double(place.y), let lon = Double(place.x) else { continue }

            let annotation = PlaceAnnotation(place: place)
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotations.append(annotation)
        }

        mapView.addAnnotations(annotations)

        // 자동 확대/중심 이동은 최초에만 하고 이후 regionDidChange에서 처리
        if mapView.annotations.count == annotations.count, !annotations.isEmpty {
            mapView.showAnnotations(annotations, animated: true)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitView
        private var lastUpdateTime: Date = Date()

        init(_ parent: MapKitView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let now = Date()
            if now.timeIntervalSince(lastUpdateTime) < 1.0 {
                return // 1초 내 중복 호출 방지
            }
            lastUpdateTime = now

            let center = mapView.centerCoordinate
            KakaoMapService().searchPoliceStations(near: center) { places in
                DispatchQueue.main.async {
                    self.parent.places = Array(places.prefix(10))
                }
            }
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? PlaceAnnotation else { return }
            parent.selectedPlace = annotation.place
        }
    }
}

// 커스텀 Annotation 클래스
class PlaceAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    let place: Place

    init(place: Place) {
        self.place = place
        self.title = place.placeName
        self.subtitle = place.roadAddressName
        self.coordinate = CLLocationCoordinate2D()
    }
}
