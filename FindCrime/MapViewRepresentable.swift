import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    var location: CLLocationCoordinate2D?
    var crimeCount: Int?
    var crimeRisk: String?
    @Binding var region: MKCoordinateRegion

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        guard let coordinate = location else { return }

        let glyphText: String
        switch crimeRisk {
        case "위험": glyphText = "🚨"
        case "보통": glyphText = "⚠️"
        case "안전": glyphText = "✅"
        default: glyphText = "❔"
        }

        let subtitleText = crimeCount != nil ? "총 \(crimeCount!)건 발생" : "건수 정보 없음"

        let annotation = CrimeAnnotation(
            coordinate: coordinate,
            title: crimeRisk ?? "위험도 정보 없음",
            subtitle: subtitleText,
            glyphText: glyphText
        )

        uiView.addAnnotation(annotation)

        // 전국 중심이면 지도 이동은 생략, 아니면 이동
        if !isShowingNationwideCenter(coordinate: coordinate) {
            let newRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
            uiView.setRegion(newRegion, animated: true)
        }
        
        // ✅ region이 바뀌었는지 비교 후, 반영
        if uiView.region.center.latitude != region.center.latitude ||
            uiView.region.center.longitude != region.center.longitude {
            uiView.setRegion(region, animated: true)
        }
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
            } else {
                view?.annotation = crimeAnnotation
            }

            // ✅ 공통 설정을 여기에 모두 다시 해줌 (재사용될 경우를 대비)
            view?.markerTintColor = .white  // 항상 흰색으로 설정
            view?.glyphText = crimeAnnotation.glyphText
            view?.titleVisibility = .visible
            view?.subtitleVisibility = .visible

            let subtitleLabel = UILabel()
            subtitleLabel.text = crimeAnnotation.subtitle
            subtitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            subtitleLabel.textColor = .darkGray
            view?.detailCalloutAccessoryView = subtitleLabel

            return view
        }

    }
}

// MARK: - 중심좌표 판별 함수
private func isShowingNationwideCenter(coordinate: CLLocationCoordinate2D) -> Bool {
    let center = CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5)
    let threshold = 0.01
    return abs(coordinate.latitude - center.latitude) < threshold &&
           abs(coordinate.longitude - center.longitude) < threshold
}

// MARK: - 사용자 정의 Annotation
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
