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
        // 기존 PlaceAnnotation 제거 (선택된 것 포함)
        let existing = mapView.annotations.compactMap { $0 as? PlaceAnnotation }
        let existingIDs = Set(existing.map { $0.place.id })
        let newIDs = Set(places.map { $0.id })

        // 새롭게 추가할 마커만 추가
        for place in places where !existingIDs.contains(place.id) {
            guard let lat = Double(place.y), let lon = Double(place.x) else { continue }
            let annotation = PlaceAnnotation(place: place,
                                             coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            mapView.addAnnotation(annotation)
        }

        // 제거 대상
        let toRemove = existing.filter { !newIDs.contains($0.place.id) }
        mapView.removeAnnotations(toRemove)
    }


    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitView
        private var lastUpdateTime: Date = Date()

        init(_ parent: MapKitView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let now = Date()
            if now.timeIntervalSince(lastUpdateTime) < 1.0 { return }
            lastUpdateTime = now

            let center = mapView.centerCoordinate
            KakaoMapService().searchPoliceStations(near: center) { places in
                DispatchQueue.main.async {
                    self.parent.places = Array(places.prefix(10))
                }
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? PlaceAnnotation else { return nil }

            let identifier = "PoliceMarker"
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.glyphText = "👮"
//            view.glyphImage = UIImage(systemName: "shield.fill")
            view.markerTintColor = .systemRed
            view.titleVisibility = .visible
            view.subtitleVisibility = .hidden
            view.canShowCallout = true
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? PlaceAnnotation else { return }

            parent.selectedPlace = annotation.place

            // ✅ 확대 애니메이션
            UIView.animate(withDuration: 0.2) {
                view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            // 마커 확대 복구
            view.transform = .identity
        }
    }
}


