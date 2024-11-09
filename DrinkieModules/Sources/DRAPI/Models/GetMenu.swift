import Foundation

public extension Model.GetMenu {
    struct Response: Codable {
        public let countryID: Int
        public let unitID: String
        public let version: Int
        public let utcTime: String
        public let configurationID: String
        public let currencyID: Int
        public let trace: String
        public let categories: [Category]
        public let items: [Item]
        
        enum CodingKeys: String, CodingKey {
            case countryID = "countryId"
            case unitID = "unitId"
            case version = "version"
            case utcTime = "utcTime"
            case configurationID = "configurationId"
            case currencyID = "currencyId"
            case trace = "trace"
            case categories = "categories"
            case items = "items"
        }
    }
    
    // MARK: - Category
    struct Category: Codable {
        public let id: String
        public let name: String
        public let parentID: String?
        public let customProperties: [CustomProperty]
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case parentID = "parentId"
            case customProperties = "customProperties"
        }
    }
    
    // MARK: - CustomProperty
    struct CustomProperty: Codable, Hashable {
        public let name: String
        public let value: String
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case value = "value"
        }
    }
    
    // MARK: - Item
    struct Item: Codable, Hashable, Identifiable {
        public let id: String
        public let name: String
        public let description: String
        public let categories: [String]
        public let imageURLTemplate: String
        public let images: [Preview]
        public let products: [Product]
        public let customProperties: [CustomProperty]
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case description = "description"
            case categories = "categories"
            case imageURLTemplate = "imageUrlTemplate"
            case images = "images"
            case products = "products"
            case customProperties = "customProperties"
        }
    }
    
    // MARK: - Product
    struct Product: Codable, Hashable, Identifiable {
        public let id: String
        public let code: Int
        public let name: String
        public let description: String
        public let sizeType: SizeType
        public let sizeName: String?
        public let sizeLabel: SizeLabel
        public let kind: Kind
        public let traits: Traits
        public let prices: [Price]
        public let imageURLTemplate: String
        public let images: [Preview]
        public let banner: Banner
        public let definition: FoodValue
        public let foodValue: FoodValue?
        public let composition: Composition?
        public let compositionDescription: String?
        public let containAllergens: String?
        public let canContainAllergens: String?
        public let digitalContent: String?
        public let customProperties: [CustomProperty]
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case code = "code"
            case name = "name"
            case description = "description"
            case sizeType = "sizeType"
            case sizeName = "sizeName"
            case sizeLabel = "sizeLabel"
            case kind = "kind"
            case traits = "traits"
            case prices = "prices"
            case imageURLTemplate = "imageUrlTemplate"
            case images = "images"
            case banner = "banner"
            case definition = "definition"
            case foodValue = "foodValue"
            case composition = "composition"
            case compositionDescription = "compositionDescription"
            case containAllergens = "containAllergens"
            case canContainAllergens = "canContainAllergens"
            case digitalContent = "digitalContent"
            case customProperties = "customProperties"
        }
    }
    
    // MARK: - Banner
    struct Banner: Codable, Hashable {
        public let type: String
        public let videos: [Frame]
        public let preview: Preview
        public let theme: Theme?
        public let label: String?
        public let images: [Preview]
        public let frame: Frame?
        
        enum CodingKeys: String, CodingKey {
            case type = "type"
            case videos = "videos"
            case preview = "preview"
            case theme = "theme"
            case label = "label"
            case images = "images"
            case frame = "frame"
        }
    }
    
    // MARK: - Frame
    struct Frame: Codable, Hashable {
        public let url: String
        
        enum CodingKeys: String, CodingKey {
            case url = "url"
        }
    }
    
    // MARK: - Preview
    struct Preview: Codable, Hashable {
        public let url: String
        public let sizeType: SizeType
        public let width: Int
        public let height: Int
        
        enum CodingKeys: String, CodingKey {
            case url = "url"
            case sizeType = "sizeType"
            case width = "width"
            case height = "height"
        }
    }
    
    enum SizeType: String, Codable, Hashable {
        case large = "Large"
        case medium = "Medium"
        case none = "None"
        case small = "Small"
    }
    
    enum Theme: String, Codable, Hashable {
        case dark = "dark"
        case light = "light"
        case lightdark = "lightdark"
    }
    
    // MARK: - Composition
    struct Composition: Codable, Hashable {
        public let groups: [Group]
        
        enum CodingKeys: String, CodingKey {
            case groups = "groups"
        }
    }
    
    // MARK: - Group
    struct Group: Codable, Hashable {
        public let code: String
        public let name: String
        public let choiceType: ChoiceType
        public let totalQuantityMin: Int
        public let totalQuantityMax: Int
        public let ingredients: [Ingredient]
        
        enum CodingKeys: String, CodingKey {
            case code = "code"
            case name = "name"
            case choiceType = "choiceType"
            case totalQuantityMin = "totalQuantityMin"
            case totalQuantityMax = "totalQuantityMax"
            case ingredients = "ingredients"
        }
    }
    
    enum ChoiceType: String, Codable, Hashable {
        case multi = "Multi"
        case none = "None"
        case single = "Single"
    }
    
    // MARK: - Ingredient
    struct Ingredient: Codable, Hashable {
        public let id: String
        public let code: Int
        public let name: String
        public let description: String?
        public let imageURLTemplate: String
        public let images: [Preview]
        public let quantity: Int
        public let quantityVariations: [QuantityVariation]
        public let materialTypeID: String
        public let receiptID: String?
        public let toppingID: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case code = "code"
            case name = "name"
            case description = "description"
            case imageURLTemplate = "imageUrlTemplate"
            case images = "images"
            case quantity = "quantity"
            case quantityVariations = "quantityVariations"
            case materialTypeID = "materialTypeId"
            case receiptID = "receiptId"
            case toppingID = "toppingId"
        }
    }
    
    // MARK: - QuantityVariation
    struct QuantityVariation: Codable, Hashable {
        public let name: String
        public let quantity: Int
        public let price: Int
        public let foodValue: FoodValue
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case quantity = "quantity"
            case price = "price"
            case foodValue = "foodValue"
        }
    }
    
    // MARK: - FoodValue
    struct FoodValue: Codable, Hashable {
        public let fats: Double?
        public let proteins: Double?
        public let carbohydrates: Double?
        public let kiloCalories: Double?
        public let weight: Double?
        
        enum CodingKeys: String, CodingKey {
            case fats = "fats"
            case proteins = "proteins"
            case carbohydrates = "carbohydrates"
            case kiloCalories = "kiloCalories"
            case weight = "weight"
        }
        
        public init(fats: Double?, proteins: Double?, carbohydrates: Double?, kiloCalories: Double?, weight: Double?) {
            self.fats = fats
            self.proteins = proteins
            self.carbohydrates = carbohydrates
            self.kiloCalories = kiloCalories
            self.weight = weight
        }
    }
    
    enum Kind: String, Codable, Hashable {
        case material = "Material"
    }
    
    // MARK: - Price
    struct Price: Codable, Hashable {
        public let level: Int
        public let value: Int
        
        enum CodingKeys: String, CodingKey {
            case level = "level"
            case value = "value"
        }
    }
    
    enum SizeLabel: String, Codable, Hashable {
        case empty = ""
        case l = "L"
        case m = "M"
        case s = "S"
    }
    
    // MARK: - Traits
    struct Traits: Codable, Hashable {
        public let drink: Bool
        public let food: Bool
        
        enum CodingKeys: String, CodingKey {
            case drink = "drink"
            case food = "food"
        }
    }
}
