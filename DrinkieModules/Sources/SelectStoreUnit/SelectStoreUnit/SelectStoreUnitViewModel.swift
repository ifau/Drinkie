import Foundation
import DRAPI
import UIKit

final class SelectStoreUnitViewModel: ObservableObject {
    
    enum State {
        case notRequested
        case loading
        case loaded([UnitModel], closeEnabled: Bool)
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
        case .selectedUnit(let unit): dependencies.dismissPresentation()
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
                state = .loaded(chain.storeUnits.map(self.map(responseUnit:)), closeEnabled: closeEnabled)
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
    let isOpen: Bool
    let openDescription: String
    
    init(unit: DRAPI.Model.GetChain.StoreUnit,
         pictures: [UnitPicture],
         isSelected: Bool,
         calendar: Calendar = Calendar.current,
         nowDate: Date = Date.now) {
        self.unit = unit
        self.pictures = pictures
        self.isSelected = isSelected
        
        let days: [DRAPI.Model.GetChain.DayEnum] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        let currentHour = calendar.component(.hour, from: nowDate)
        let currentMinute = calendar.component(.minute, from: nowDate)
        let currentDay = days[(calendar.dateComponents([.weekday], from: nowDate).weekday ?? 1) - 1]
        
        func minutes(hour: Int, minutes: Int) -> Int { return hour * 60 + minutes }
        
        func nextDay() -> DRAPI.Model.GetChain.DayElement? {
            let reorderedDays = days.split(separator: currentDay, maxSplits: 2).reversed().flatMap { $0 }
            for day in reorderedDays {
                if let nextDay = unit.schedule.days.first(where: { $0.day == day && $0.period != nil }) {
                    return nextDay
                }
            }
            return nil
        }
        
        // TODO: - Handle localisation
        func shortWeekLabel(_ day: DRAPI.Model.GetChain.DayEnum) -> String {
            String(day.rawValue.lowercased().prefix(3))
        }
        
        // TODO: rewrite without so many else branches
        if let currentDaySchedule = unit.schedule.days.first(where: { $0.day == currentDay }),
           let start = currentDaySchedule.period?.start,
           let end = currentDaySchedule.period?.end {
            if minutes(hour: currentHour, minutes: currentMinute) < minutes(hour: start.hour, minutes: start.minute) {
                let hour = start.hour.formatted(.number.precision(.integerLength(2)))
                let minute = start.minute.formatted(.number.precision(.integerLength(2)))
                self.isOpen = false
                self.openDescription = "open today at \(hour):\(minute)"
            } else if minutes(hour: currentHour, minutes: currentMinute) < minutes(hour: end.hour, minutes: end.minute) {
                let hour = end.hour.formatted(.number.precision(.integerLength(2)))
                let minute = end.minute.formatted(.number.precision(.integerLength(2)))
                self.isOpen = true
                self.openDescription = "till \(hour):\(minute)"
            } else {
                self.isOpen = false
                if let nextDay = nextDay(), let start = nextDay.period?.start {
                    let hour = start.hour.formatted(.number.precision(.integerLength(2)))
                    let minute = start.minute.formatted(.number.precision(.integerLength(2)))
                    self.openDescription = "open \(shortWeekLabel(nextDay.day)) at \(hour):\(minute)"
                } else {
                    self.openDescription = ""
                }
            }
        } else {
            self.isOpen = false
            if let nextDay = nextDay(), let start = nextDay.period?.start {
                let hour = start.hour.formatted(.number.precision(.integerLength(2)))
                let minute = start.minute.formatted(.number.precision(.integerLength(2)))
                self.openDescription = "open \(shortWeekLabel(nextDay.day)) at \(hour):\(minute)"
            } else {
                self.openDescription = ""
            }
        }
    }
    
    var alias: String { unit.alias }
    var address: String { unit.address.text ?? "" }
    var orientation: String { unit.orientation }
}

extension UnitModel: Hashable, Identifiable {
    var id: String { unit.id }
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
