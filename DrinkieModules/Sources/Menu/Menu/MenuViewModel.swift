import Foundation
import Combine
import DRAPI
import UIKit

typealias Tab = DRAPI.Model.GetMenuView.Tab
typealias ModularTab = DRAPI.Model.GetMenuView.ModularTab
typealias Banner = DRAPI.Model.GetMenuView.Banner
typealias ProductBanner = DRAPI.Model.GetMenuView.ProductBanner
typealias ProductLink = DRAPI.Model.GetMenuView.ProductLink
typealias ProductListBlock = DRAPI.Model.GetMenuView.ProductListBlock
typealias PromotionBanner = DRAPI.Model.GetMenuView.PromotionBanner
typealias PromotionLink = DRAPI.Model.GetMenuView.PromotionLink
typealias PromotionListBlock = DRAPI.Model.GetMenuView.PromotionListBlock

final class MenuViewModel {
    
    enum State {
        case notRequested
        case loading
        case loaded(DRAPI.Model.GetMenuView.MenuView)
        case failed(Error)
    }
    
    enum Event {
        case viewDidAppear
        case tryAgainButtonPressed
        case productLinkTap(ProductLink)
        case promotionLinkTap(PromotionLink)
    }
    
    var state: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }
    private(set) var input = PassthroughSubject<Event, Never>()
    
    private var getMenuViewResponse: DRAPI.Model.GetMenuView.Response?
    private var getMenuResponse: DRAPI.Model.GetMenu.Response?
    private var getPromotionsResponse: DRAPI.Model.GetPromotions.Response?
    private var getStopsResponse: DRAPI.Model.GetStops.Response?
    
    private var getMenuTask: Task<Void, Never>?
    private var subscriptions: [AnyCancellable] = []
    private let stateSubject = CurrentValueSubject<State, Never>(.notRequested)
    private let dependencies: MenuModule.Dependencies
    
    init(dependencies: MenuModule.Dependencies) {
        self.dependencies = dependencies
        createInputSubscription()
    }
    
    private func createInputSubscription() {
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear: self?.tryLoadMenu()
            case .tryAgainButtonPressed: self?.tryLoadMenu()
            case .productLinkTap(let productLink): ()
            case .promotionLinkTap(let promotionLink): ()
            }
        }
        .store(in: &subscriptions)
    }
}

private extension MenuViewModel {
    
    func tryLoadMenu() {
        guard getMenuTask == nil else { return }
        guard getMenuResponse == nil || getMenuViewResponse == nil else { return }
        
        getMenuTask = Task {
            defer { getMenuTask = nil }
            stateSubject.send(.loading)
            
            do {
                let menuViewResponse = try await dependencies.fetchMenuView()
                let menuResponse = try await dependencies.fetchMenu()
                let stopsResponse = try await dependencies.fetchStops()
                
                self.getMenuViewResponse = menuViewResponse
                self.getMenuResponse = menuResponse
                self.getStopsResponse = stopsResponse
                
                if isMenuViewContainsPromotions(menuViewResponse) {
                    self.getPromotionsResponse = try await dependencies.fetchPromotions()
                }
                
                stateSubject.send(.loaded(menuViewResponse.menuView))
            } catch {
                stateSubject.send(.failed(error))
            }
        }
    }
    
    func isMenuViewContainsPromotions(_ menuViewReponse: DRAPI.Model.GetMenuView.Response) -> Bool {
        
        let hasPromoBanners = menuViewReponse.menuView.tabs
            .map { $0.modularTab }
            .compactMap { $0.banner.promotionBanner }
            .count > 0
        
        let hasPromoSections = menuViewReponse.menuView.tabs
            .flatMap { $0.modularTab.sections }
            .flatMap { $0.blocks }
            .compactMap { $0.promotionListBlock }
            .count > 0
        
        return hasPromoBanners || hasPromoSections
    }
}

extension MenuViewModel: MenuViewAttributesProvider {
    func productLinkAttributes(_ productLink: ProductLink) -> ProductLinkAttributes? {
        
        guard let getMenuResponse else { return nil }
        guard let item = getMenuResponse.items.flatMap({ $0.products }).first(where: { $0.id == productLink.id }) else { return nil }
        
        let inStopList = getStopsResponse?.products.first(where: { $0.productID == productLink.id }) != nil
        let stocksQuantity = getStopsResponse?.productStocks.first(where: { $0.productID == productLink.id })?.quantity ?? Int.max
        
        let loadImage: (_ size: CGSize) async throws -> UIImage? = { [weak self] size in
            return try await self?.image(templateURL: item.imageURLTemplate, size: size)
        }
        
        let loadBannerPreviewImage: () async throws -> UIImage? = { [weak self] in
            guard let previewURL = URL(string: item.banner.preview.url) else { return nil }
            return try await self?.image(url: previewURL)
        }
        
        let loadBannerVideo: () async throws -> URL? = { [weak self] in
            guard let previewURL = URL(string: item.banner.videos.first?.url ?? "") else { return nil }
            return try await self?.dependencies.downloadURL(previewURL)
        }
        
        // TODO: Remove hardcoded currency
        return ProductLinkAttributes(localizedTitle: item.name,
                                     localizedPrice: "RUB \(productLink.price.formatted())",
                                     isAvailable: !(inStopList || stocksQuantity == 0),
                                     loadImage: loadImage,
                                     loadBannerPreviewImage: loadBannerPreviewImage,
                                     loadBannerVideo: loadBannerVideo)
    }
    
    func promotionLinkAttributes(_ promotionLink: PromotionLink) -> PromotionLinkAttributes? {
        guard let getPromotionsResponse else { return nil }
        guard let promo = getPromotionsResponse.first(where: { $0.id == promotionLink.id }) else { return nil }
        
        var actionTitle: String?
        
        // TODO: Add promotions button action types
        if let action = promo.action, let _ = action.couponCode {
            actionTitle = "Sign in & apply"
        }
        
        let loadImage: (_ size: CGSize) async throws -> UIImage? = { [weak self] _ in
            var imageURLString = promo.images.first { ($0.tags ?? []).contains("4x3") }?.url
            if imageURLString == nil {
                imageURLString = promo.images.first?.url
            }
            guard let imageURLString, let imageURL = URL(string: imageURLString) else { return nil }
            return try await self?.image(url: imageURL)
        }
        
        let loadBannerPreviewImage: () async throws -> UIImage? = { [weak self] in
            guard let previewURL = URL(string: promo.banner.preview.url) else { return nil }
            return try await self?.image(url: previewURL)
        }
        
        let loadBannerVideo: () async throws -> URL? = { [weak self] in
            guard let previewURL = URL(string: promo.banner.videos.first?.url ?? "") else { return nil }
            return try await self?.dependencies.downloadURL(previewURL)
        }
        
        return PromotionLinkAttributes(localizedTitle: promo.title,
                                       localizedDescription: promo.description,
                                       actionLocalizedTitle: actionTitle,
                                       loadImage: loadImage,
                                       loadBannerPreviewImage: loadBannerPreviewImage,
                                       loadBannerVideo: loadBannerVideo)
    }
    
    func image(templateURL: String, size: CGSize) async throws -> UIImage {
        
        var templateURL = templateURL
        templateURL = templateURL.replacingOccurrences(of: "{width}", with: size.width.formatted())
        templateURL = templateURL.replacingOccurrences(of: "{height}", with: size.height.formatted())
        templateURL = templateURL.replacingOccurrences(of: "{ext}", with: "heic")
        
        guard let url = URL(string: templateURL) else {
            throw URLError(URLError.badURL)
        }
        
        return try await image(url: url)
    }
    
    func image(url: URL) async throws -> UIImage {
        let localURL = try await dependencies.downloadURL(url)
        if let image = UIImage(contentsOfFile: localURL.path) {
            return image
        }
        throw URLError(URLError.badURL)
    }
}
