import SwiftUI
import MapKit
import CoreLocation

struct MapKitView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    let places: [Place]
    @Binding var selectedPlace: Place?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
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

        if let first = annotations.first {
            let region = MKCoordinateRegion(center: first.coordinate,
                                            latitudinalMeters: 3000,
                                            longitudinalMeters: 3000)
            mapView.setRegion(region, animated: true)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitView

        init(_ parent: MapKitView) {
            self.parent = parent
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
