import SwiftUI
import MapKit

struct MapWrapperView: UIViewRepresentable {
    
    let annotations: [UnitAnotation]
    @Binding var selectedAnnotation: UnitAnotation?
    @Binding var region: MKCoordinateRegion?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.directionalLayoutMargins = .zero
        
        mapView.register(UnitAnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(UnitAnotationClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        mapView.addAnnotations(annotations)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // mapView.removeAnnotations(mapView.annotations)
        // mapView.addAnnotations(annotations)
        
        if let mapRegion = region {
            let region = mapView.regionThatFits(mapRegion)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(for: self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        private let parent: MapWrapperView
        
        init(for parent: MapWrapperView) {
            self.parent = parent
            super.init()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            switch annotation {
            case is MKClusterAnnotation:
                let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier) as? UnitAnotationClusterView
                clusterView?.annotation = annotation
                return clusterView
                
            case is UnitAnotation:
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as? UnitAnotationView
                annotationView?.annotation = annotation
                return annotationView
                
            default:
                return nil
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? UnitAnotation else { return }
            
            let verticalOffset: CGFloat = 300
            var coordinatePoint = MKMapPoint(annotation.coordinate)
            coordinatePoint.y += verticalOffset * mapView.visibleMapRect.size.height / mapView.bounds.size.height
            mapView.setCenter(coordinatePoint.coordinate, animated: true)
            
            parent.selectedAnnotation = annotation
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            parent.selectedAnnotation = nil
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.region = mapView.region
            }
        }
    }
}
