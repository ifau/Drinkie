import Foundation
import Combine
import SwiftUI
import DRAPI

public enum ProductDetailsModule {
    
    public struct Dependencies {
        public var product: Model.GetMenu.Product
        public var relatedProducts: [Model.GetMenu.Product]
        public var selectedStoreUnit: AnyPublisher<(unit: DRAPI.Model.GetChain.StoreUnit, currency: DRAPI.Model.GetChain.Currency)?, Never>
        public var downloadURL: (_ remoteURL : URL) async throws -> URL
        public var fetchStops: () async throws -> DRAPI.Model.GetStops.Response
        
        public init(product: Model.GetMenu.Product,
                    relatedProducts: [Model.GetMenu.Product],
                    selectedStoreUnit: AnyPublisher<(unit: DRAPI.Model.GetChain.StoreUnit, currency: DRAPI.Model.GetChain.Currency)?, Never>,
                    downloadURL: @escaping (_: URL) async throws -> URL,
                    fetchStops: @escaping () async throws -> DRAPI.Model.GetStops.Response) {
            self.product = product
            self.relatedProducts = relatedProducts
            self.selectedStoreUnit = selectedStoreUnit
            self.downloadURL = downloadURL
            self.fetchStops = fetchStops
        }
    }
    
    public static func rootViewController(dependencies: Dependencies) -> ProductDetailsViewController {
        let viewController = ProductDetailsViewController()
        viewController.viewModel = ProductDetailsViewModel(dependencies: dependencies)
            
        return viewController
    }
    
    public static func rootView(dependencies: Dependencies) -> ProductDetailsModule.ProductDetailsRootView {
        ProductDetailsModule.ProductDetailsRootView(dependencies: dependencies)
    }
}

extension ProductDetailsModule {
    
    public struct ProductDetailsRootView: UIViewControllerRepresentable {
        
        let dependencies: ProductDetailsModule.Dependencies
        
        public func makeUIViewController(context: Context) -> ProductDetailsViewController {
            return ProductDetailsModule.rootViewController(dependencies: dependencies)
        }
        
        public func updateUIViewController(_ viewController: ProductDetailsViewController, context: Context) {
        }
    }
}
