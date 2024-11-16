import Foundation
import UIKit
import SwiftUI
import Combine
import DRAPI

public enum MenuModule {
    
    public struct Dependencies {
        
        public var selectedStoreUnit: AnyPublisher<(unit: DRAPI.Model.GetChain.StoreUnit, currency: DRAPI.Model.GetChain.Currency)?, Never>
        public var fetchMenuView: () async throws -> DRAPI.Model.GetMenuView.Response
        public var fetchMenu: () async throws -> DRAPI.Model.GetMenu.Response
        public var fetchPromotions: () async throws -> DRAPI.Model.GetPromotions.Response
        public var fetchStops: () async throws -> DRAPI.Model.GetStops.Response
        public var downloadURL: (_ remoteURL : URL) async throws -> URL
        public var navigateToProductDetails: (_ product: DRAPI.Model.GetMenu.Product, _ relatedProducts: [DRAPI.Model.GetMenu.Product]) -> Void
        public var navigateToSelectStoreUnit: () -> Void
        
        public init(selectedStoreUnit: AnyPublisher<(unit: DRAPI.Model.GetChain.StoreUnit, currency: DRAPI.Model.GetChain.Currency)?, Never>,
                    fetchMenuView: @escaping () async throws -> DRAPI.Model.GetMenuView.Response,
                    fetchMenu: @escaping () async throws -> DRAPI.Model.GetMenu.Response,
                    fetchPromotions: @escaping () async throws -> DRAPI.Model.GetPromotions.Response,
                    fetchStops: @escaping () async throws -> DRAPI.Model.GetStops.Response,
                    downloadURL: @escaping (_: URL) async throws -> URL,
                    navigateToProductDetails: @escaping (DRAPI.Model.GetMenu.Product, [DRAPI.Model.GetMenu.Product]) -> Void,
                    navigateToSelectStoreUnit: @escaping () -> Void) {
            
            self.selectedStoreUnit = selectedStoreUnit
            self.fetchMenuView = fetchMenuView
            self.fetchMenu = fetchMenu
            self.fetchPromotions = fetchPromotions
            self.fetchStops = fetchStops
            self.downloadURL = downloadURL
            self.navigateToProductDetails = navigateToProductDetails
            self.navigateToSelectStoreUnit = navigateToSelectStoreUnit
        }
    }
    
    public static func rootViewController(dependencies: Dependencies) -> MenuViewController {
        let viewController = MenuViewController()
        viewController.viewModel = MenuViewModel(dependencies: dependencies)
            
        return viewController
    }
    
    public static func rootView(dependencies: Dependencies) -> MenuModule.MenuRootView {
        MenuModule.MenuRootView(dependencies: dependencies)
    }
}

extension MenuModule {
    
    public struct MenuRootView: UIViewControllerRepresentable {
        
        let dependencies: MenuModule.Dependencies
        
        public func makeUIViewController(context: Context) -> MenuViewController {
            return MenuModule.rootViewController(dependencies: dependencies)
        }
        
        public func updateUIViewController(_ viewController: MenuViewController, context: Context) {
        }
    }
}

