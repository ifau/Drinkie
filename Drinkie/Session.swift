import Foundation
import SwiftUI
import DRAPI

final class Session: ObservableObject {
    @Published var storeUnit: StoreUnitDetails?
}

struct StoreUnitDetails: Equatable {
    let unit: DRAPI.Model.GetChain.StoreUnit
    let currency: DRAPI.Model.GetChain.Currency
}

//

private struct SessionKey: EnvironmentKey {
    static let defaultValue = Session()
}

extension EnvironmentValues {
    var currentSession: Session {
        get { self[SessionKey.self] }
        set { self[SessionKey.self] = newValue }
    }
}
