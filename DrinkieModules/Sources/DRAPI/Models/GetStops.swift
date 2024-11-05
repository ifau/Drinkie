import Foundation

public extension Model.GetStops {
    
    struct Response: Codable {
        public let workState: WorkState
        public let products: [Product]
        public let materials: [Material]
        public let productStocks: [ProductStock]
        
        public enum CodingKeys: String, CodingKey {
            case workState = "workState"
            case products = "products"
            case materials = "materials"
            case productStocks = "productStocks"
        }
    }
    
    // MARK: - Material
    struct Material: Codable {
        public let materialTypeID: String
        
        public enum CodingKeys: String, CodingKey {
            case materialTypeID = "materialTypeId"
        }
    }
    
    // MARK: - ProductStock
    struct ProductStock: Codable {
        public let productID: String
        public let quantity: Int
        
        public enum CodingKeys: String, CodingKey {
            case productID = "productId"
            case quantity = "quantity"
        }
    }
    
    // MARK: - Product
    struct Product: Codable {
        public let productID: String
        
        public enum CodingKeys: String, CodingKey {
            case productID = "productId"
        }
    }
    
    // MARK: - WorkState
    struct WorkState: Codable {
        public let status: String
        public let startUTCTime: String
        public let endUTCTime: String
        
        public enum CodingKeys: String, CodingKey {
            case status = "status"
            case startUTCTime = "startUtcTime"
            case endUTCTime = "endUtcTime"
        }
    }
}
