import Foundation

public extension Model.GetMenuView {
    
    struct Response: Codable {
        public let menuView: MenuView
        
        public enum CodingKeys: String, CodingKey {
            case menuView = "menuView"
        }
    }
    
    // MARK: - MenuView
    struct MenuView: Codable, Hashable {
        public let unitID: String
        public let tabs: [Tab]
        
        public enum CodingKeys: String, CodingKey {
            case unitID = "unitId"
            case tabs = "tabs"
        }
    }
    
    // MARK: - Tab
    struct Tab: Codable, Hashable {
        public let id: String
        public let title: String
        public let type: TabType
        public let modularTab: ModularTab
        
        public enum CodingKeys: String, CodingKey {
            case id = "id"
            case title = "title"
            case type = "type"
            case modularTab = "modularTab"
        }
    }
    
    // MARK: - ModularTab
    struct ModularTab: Codable, Hashable {
        public let banner: Banner
        public let sections: [Section]
        
        public enum CodingKeys: String, CodingKey {
            case banner = "banner"
            case sections = "sections"
        }
    }
    
    // MARK: - Banner
    struct Banner: Codable, Hashable {
        public let type: BannerType
        public let promotionBanner: PromotionBanner?
        public let productBanner: ProductBanner?
        
        public enum CodingKeys: String, CodingKey {
            case type = "type"
            case promotionBanner = "promotionBanner"
            case productBanner = "productBanner"
        }
    }
    
    // MARK: - ProductBanner
    struct ProductBanner: Codable, Hashable {
        public let debug: String
        public let productLink: ProductLink
        
        public enum CodingKeys: String, CodingKey {
            case debug = "debug"
            case productLink = "productLink"
        }
    }
    
    // MARK: - ProductLink
    struct ProductLink: Codable, Hashable {
        public let debug: String
        public let utm: String?
        public let status: Status
        public let id: String
        public let price: Double
        public let action: Action
        
        public enum CodingKeys: String, CodingKey {
            case debug = "debug"
            case utm = "utm"
            case status = "status"
            case id = "id"
            case price = "price"
            case action = "action"
        }
    }
    
    enum Action: String, Codable {
        case addToCart = "AddToCart"
        case showDetails = "ShowDetails"
    }
    
    enum Status: String, Codable {
        case good = "Good"
    }
    
    // MARK: - PromotionBanner
    struct PromotionBanner: Codable, Hashable {
        public let promotionLink: PromotionLink
        
        public enum CodingKeys: String, CodingKey {
            case promotionLink = "promotionLink"
        }
    }
    
    // MARK: - PromotionLink
    struct PromotionLink: Codable, Hashable {
        public let debug: String
        public let id: String
        
        public enum CodingKeys: String, CodingKey {
            case debug = "debug"
            case id = "id"
        }
    }
    
    enum BannerType: String, Codable {
        case product = "Product"
        case promotion = "Promotion"
    }
    
    // MARK: - Section
    struct Section: Codable, Hashable {
        public let debug: String
        public let title: String?
        public let blocks: [Block]
        
        public enum CodingKeys: String, CodingKey {
            case debug = "debug"
            case title = "title"
            case blocks = "blocks"
        }
    }
    
    // MARK: - Block
    struct Block: Codable, Hashable {
        public let type: BlockType
        public let productListBlock: ProductListBlock?
        public let promotionListBlock: PromotionListBlock?
        
        public enum CodingKeys: String, CodingKey {
            case type = "type"
            case promotionListBlock = "promotionListBlock"
            case productListBlock = "productListBlock"
        }
    }
    
    // MARK: - ProductListBlock
    struct ProductListBlock: Codable, Hashable {
        public let debug: String
        public let productLinks: [ProductLink]
        public let utm: String?
        public let style: ProductListBlockStyle?
        
        public enum CodingKeys: String, CodingKey {
            case debug = "debug"
            case productLinks = "productLinks"
            case utm = "utm"
            case style = "style"
        }
    }
    
    enum ProductListBlockStyle: String, Codable {
        case longHeightCells = "LongHeightCells"
        case largeVideoCells = "LargeVideoCells"
    }
    
    // MARK: - PromotionListBlock
    struct PromotionListBlock: Codable, Hashable {
        public let promotionLinks: [PromotionLink]
        public let utm: String

        public enum CodingKeys: String, CodingKey {
            case promotionLinks = "promotionLinks"
            case utm = "utm"
        }
    }
    
    enum BlockType: String, Codable {
        case productList = "ProductList"
        case promotionList = "PromotionList"
    }
    
    enum TabType: String, Codable {
        case modular = "Modular"
    }
}
