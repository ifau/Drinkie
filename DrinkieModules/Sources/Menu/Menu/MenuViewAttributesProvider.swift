import Foundation
import UIKit

protocol MenuViewAttributesProvider: AnyObject {
    func productLinkAttributes(_ productLink: ProductLink) -> ProductLinkAttributes?
    func promotionLinkAttributes(_ promotionLink: PromotionLink) -> PromotionLinkAttributes?
}

struct ProductLinkAttributes {
    let localizedTitle: String
    let localizedPrice: String
    let isAvailable: Bool
    
    var loadImage: (_ size: CGSize) async throws -> UIImage?
    var loadBannerPreviewImage: () async throws -> UIImage?
    var loadBannerVideo: () async throws -> URL?
}

struct PromotionLinkAttributes {
    let localizedTitle: String
    let localizedDescription: String
    let actionLocalizedTitle: String?
    
    var loadImage: (_ size: CGSize) async throws -> UIImage?
    var loadBannerPreviewImage: () async throws -> UIImage?
    var loadBannerVideo: () async throws -> URL?
}
