import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    var location: CLLocationCoordinate2D?
    var crimeCount: Int?
    var crimeRisk: String?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        // 초기 줌: 대한민국 중심
        let koreaCenter = CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5)
        let region = MKCoordinateRegion(center: koreaCenter, latitudinalMeters: 500_000, longitudinalMeters: 500_000)
        mapView.setRegion(region, animated: false)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        guard let coordinate = location else { return }

        let glyphText: String
        switch crimeRisk {
        case "위험":
            glyphText = "🚨"
        case "보통":
            glyphText = "⚠️"
        case "안전":
            glyphText = "✅"
        default:
            glyphText = "❔"
        }

        let subtitleText = crimeCount != nil ? "총 \(crimeCount!)건 발생" : "건수 정보 없음"

        let annotation = CrimeAnnotation(
            coordinate: coordinate,
            title: crimeRisk ?? "위험도 정보 없음",
            subtitle: subtitleText,
            glyphText: glyphText
        )
        uiView.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        uiView.setRegion(region, animated: true)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let crimeAnnotation = annotation as? CrimeAnnotation else { return nil }

            let identifier = "CrimeMarker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if view == nil {
                view = MKMarkerAnnotationView(annotation: crimeAnnotation, reuseIdentifier: identifier)
                view?.canShowCallout = true
                view?.markerTintColor = .white
                view?.glyphText = crimeAnnotation.glyphText
                view?.titleVisibility = .visible
                view?.subtitleVisibility = .visible

                // ✅ 커스텀 콜아웃: 범죄 건수 텍스트
                let subtitleLabel = UILabel()
                subtitleLabel.text = crimeAnnotation.subtitle
                subtitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
                subtitleLabel.textColor = .darkGray
                view?.detailCalloutAccessoryView = subtitleLabel
            } else {
                view?.annotation = crimeAnnotation
                view?.glyphText = crimeAnnotation.glyphText
                if let label = view?.detailCalloutAccessoryView as? UILabel {
                    label.text = crimeAnnotation.subtitle
                }
            }

            return view
        }

    }
}

// 사용자 정의 MKAnnotation 클래스
class CrimeAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let glyphText: String

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, glyphText: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphText = glyphText
    }
}
