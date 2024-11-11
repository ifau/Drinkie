import Foundation
import DRAPI

final class PreviewContainer: DependencyContainer {
    
    override init() {
        super.init()
        registerMockDependencies()
    }
    
    private func registerMockDependencies() {
        
        let fetchMenuView: () async throws -> DRAPI.Model.GetMenuView.Response = { [unowned self] in
            try await Task.sleep(nanoseconds: UInt64.random(in: 1_000_000_000...2_000_000_000))
            return try decodeFromBundle(filename: "menuView", withExtension: "txt")
        }
        
        let fetchMenu: () async throws -> DRAPI.Model.GetMenu.Response = { [unowned self] in
            try decodeFromBundle(filename: "menu", withExtension: "txt")
        }
        
        let fetchPromotions: () async throws -> DRAPI.Model.GetPromotions.Response = { [unowned self] in
            try decodeFromBundle(filename: "promotions", withExtension: "txt")
        }
        
        let fetchStops: () async throws -> DRAPI.Model.GetStops.Response = { [unowned self] in
            try decodeFromBundle(filename: "stops", withExtension: "txt")
        }
        
        let fetchChain: () async throws -> DRAPI.Model.GetChain.Response = { [unowned self] in
            try decodeFromBundle(filename: "chain", withExtension: "txt")
        }
        
        let downloadURL: (_ remoteURL : URL) async throws -> URL = { url in
            let lastPathComponents = url.lastPathComponent.components(separatedBy: ".")
            
            guard lastPathComponents.count == 2,
               let name = lastPathComponents.first,
               let pathExtension = lastPathComponents.last,
               let url = Bundle.main.url(forResource: name, withExtension: pathExtension) else {
                throw URLError(URLError.unknown)
            }
            
            return url
        }
        
        register(factory: { fetchMenuView })
        register(factory: { fetchMenu })
        register(factory: { fetchPromotions })
        register(factory: { fetchStops })
        register(factory: { fetchChain })
        register(factory: { downloadURL })
    }
    
    private func decodeFromBundle<T: Codable>(filename: String, withExtension: String) throws -> T {
        
        if let fileURL = Bundle.main.url(forResource: filename, withExtension: withExtension) {
            let data = try Data(contentsOf: fileURL)
            let response = try JSONDecoder().decode(T.self, from: data)
            return response
        }
        throw URLError(URLError.unknown)
    }
}
