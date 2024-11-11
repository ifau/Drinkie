import Foundation
import SwiftUI
import DRAPI

public enum SelectStoreUnitModule {
    
    public struct Dependencies {
        public let selectedUnitId: String?
        public var downloadURL: (_ remoteURL : URL) async throws -> URL
        public var fetchChain: () async throws -> DRAPI.Model.GetChain.Response
        public var dismissPresentation: () -> Void
        
        public init(selectedUnitId: String?,
                    downloadURL: @escaping (_: URL) async throws -> URL,
                    fetchChain: @escaping () async throws -> DRAPI.Model.GetChain.Response,
                    dismissPresentation: @escaping () -> Void) {
            self.selectedUnitId = selectedUnitId
            self.downloadURL = downloadURL
            self.fetchChain = fetchChain
            self.dismissPresentation = dismissPresentation
        }
    }
    
    public static func rootView(dependencies: Dependencies) -> SelectStoreUnitView {
        let viewModel = SelectStoreUnitViewModel(dependencies: dependencies)
        return SelectStoreUnitView(viewModel: viewModel)
    }
}
