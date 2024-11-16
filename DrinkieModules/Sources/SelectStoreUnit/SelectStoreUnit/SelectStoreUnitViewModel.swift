import Foundation
import DRAPI
import UIKit

final class SelectStoreUnitViewModel: ObservableObject {
    
    enum State {
        case notRequested
        case loading
        case loaded([UnitModel], [DRAPI.Model.GetChain.Country], closeEnabled: Bool)
        case failed(Error)
    }
    
    enum Event {
        case task
        case tryAgainButtonPressed
        case closeButtonPressed
        case selectedUnit(UnitModel)
    }
    
    @Published private(set) var state: State = .notRequested
    private var loadTask: Task<Void, Never>?
    private let dependencies: SelectStoreUnitModule.Dependencies
    
    init(dependencies: SelectStoreUnitModule.Dependencies) {
        self.dependencies = dependencies
    }
    
    func onEvent(_ event: Event) {
        switch event {
        case .task: loadStoreUnits()
        case .tryAgainButtonPressed: loadStoreUnits()
        case .closeButtonPressed: dependencies.dismissPresentation()
        case .selectedUnit(let unit):
            guard case let .loaded(_, countries, _) = state else { return }
            guard let country = countries.first(where: { $0.id == unit.unit.countryID }) else { return }
            dependencies.selectionHandler(unit.unit, country)
        }
    }
}

private extension SelectStoreUnitViewModel {
    
    func loadStoreUnits() {
        guard loadTask == nil else { return }
        
        loadTask = Task { @MainActor in
            defer { loadTask = nil }
            
            do {
                state = .loading
                let chain = try await dependencies.fetchChain()
                let closeEnabled = dependencies.selectedUnitId != nil
                state = .loaded(chain.storeUnits.map(self.map(responseUnit:)), chain.countries, closeEnabled: closeEnabled)
            } catch {
                state = .failed(error)
            }
        }
    }
    
    func map(responseUnit: DRAPI.Model.GetChain.StoreUnit) -> UnitModel {
        let pictures = responseUnit.images.compactMap { link -> UnitPicture? in
            guard let url = URL(string: link.url) else { return nil }
            return UnitPicture(urlString: link.url, load: { [weak self] in
                guard let localURL = try await self?.dependencies.downloadURL(url) else { return nil }
                return UIImage(contentsOfFile: localURL.path)
            })
        }
        
        return UnitModel(unit: responseUnit, pictures: pictures, isSelected: dependencies.selectedUnitId == responseUnit.id)
    }
}

struct UnitModel {
    let unit: DRAPI.Model.GetChain.StoreUnit
    let pictures: [UnitPicture]
    let isSelected: Bool
}

extension UnitModel: Hashable, Identifiable {
    var id: String { unit.id }
    var alias: String { unit.alias }
    var address: String { unit.address.text ?? "" }
    var orientation: String { unit.orientation }
    
    var isOpen: Bool {
        guard case .openUntil = unit.schedule.openStatus(relaitiveTo: .now) else { return false }
        return true
    }
    
    var openDescription: String {
        // TODO: handle localisation
        switch unit.schedule.openStatus(relaitiveTo: .now) {
        case .openUntil(_, let time):
            let hour = time.hour.formatted(.number.precision(.integerLength(2)))
            let minutes = time.minute.formatted(.number.precision(.integerLength(2)))
            return "till \(hour):\(minutes)"
            
        case .closedUntil(let day, let time):
            let hour = time.hour.formatted(.number.precision(.integerLength(2)))
            let minutes = time.minute.formatted(.number.precision(.integerLength(2)))
            let shortWeekDay = day.rawValue.lowercased().prefix(3)
            return "open \(shortWeekDay) at \(hour):\(minutes)"
            
        case .unknown: return "closed"
        }
    }
}

struct UnitPicture: Hashable, Identifiable {
    
    var id: String { urlString }
    private let urlString: String
    
    let load: () async throws -> UIImage?
    
    init(urlString: String, load: @escaping () async throws -> UIImage?) {
        self.urlString = urlString
        self.load = load
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(urlString)
    }
    
    static func ==(lhs: UnitPicture, rhs: UnitPicture) -> Bool {
        return lhs.urlString == rhs.urlString
    }
}
