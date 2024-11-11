import SwiftUI
import MapKit
import DRUIKit

struct MapSelectionView: View {
    
    let units: [UnitModel]
    let selectionHandler: ((UnitModel?) -> Void)?
    
    @State private var selectedAnnotation: UnitAnotation?
    @State private var region: MKCoordinateRegion?
    
    init(units: [UnitModel], selectionHandler: ((UnitModel?) -> Void)?) {
        self.units = units
        self.selectionHandler = selectionHandler
        
        var initialRegion: MKCoordinateRegion? = nil
        
        if let selected = units.first(where: { $0.isSelected }) {
            initialRegion = MKCoordinateRegion(center: .init(latitude: selected.unit.coordinates.latitude, longitude: selected.unit.coordinates.longitude), span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1))
        } else if let first = units.first {
            initialRegion = MKCoordinateRegion(center: .init(latitude: first.unit.coordinates.latitude, longitude: first.unit.coordinates.longitude), span: .init(latitudeDelta: 5, longitudeDelta: 5))
        }
        _region = .init(wrappedValue: initialRegion)
    }
    
    var body: some View {
        MapWrapperView(annotations: units.map({ UnitAnotation(unit: $0) }),
                       selectedAnnotation: $selectedAnnotation,
                       region: $region)
        .onChange(of: selectedAnnotation) { oldValue, newValue in
            selectionHandler?(selectedAnnotation?.unit)
        }
    }
}

final class UnitAnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D { .init(latitude: unit.unit.coordinates.latitude, longitude: unit.unit.coordinates.longitude) }
    
    let unit: UnitModel
    
    init(unit: UnitModel) {
        self.unit = unit
    }
}

