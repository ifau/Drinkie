import Foundation

public extension Model.GetPromotions {

    typealias Response = [Promotion]
    
    // MARK: - WelcomeElement
    struct Promotion: Codable {
        public let id: String
        public let code: Int
        public let isPublic: Bool
        public let name: String
        public let title: String
        public let description: String
        public let banner: Banner
        public let images: [Preview]
        public let action: Action?
        public let countLimit: Int
//        let timeLimit: JSONNull?
//        let periodLimit: JSONNull?
        public let customProperties: [CustomProperty]
        public let couponCode: String
        public let bannerPath: String
        
        public enum CodingKeys: String, CodingKey {
            case id = "id"
            case code = "code"
            case isPublic = "public"
            case name = "name"
            case title = "title"
            case description = "description"
            case banner = "banner"
            case images = "images"
            case action = "action"
            case countLimit = "countLimit"
//            case timeLimit = "timeLimit"
//            case periodLimit = "periodLimit"
            case customProperties = "customProperties"
            case couponCode = "couponCode"
            case bannerPath = "bannerPath"
        }
    }
    
    // MARK: - Action
    struct Action: Codable {
        public let type: String
        public let text: String?
        public let couponCode: String?
        public let link: String?
        
        public enum CodingKeys: String, CodingKey {
            case type = "type"
            case text = "text"
            case couponCode = "couponCode"
            case link = "link"
        }
    }
    
    // MARK: - Banner
    struct Banner: Codable {
        public let images: [Preview]
        public let videos: [Video]
        public let preview: Preview
        public let theme: String
        public let type: String
        
        public enum CodingKeys: String, CodingKey {
            case images = "images"
            case videos = "videos"
            case preview = "preview"
            case theme = "theme"
            case type = "type"
        }
    }
    
    // MARK: - Preview
    struct Preview: Codable {
        public let url: String
        public let sizeType: String
        public let width: Int
        public let height: Int
        public let tags: [String]?
        
        public enum CodingKeys: String, CodingKey {
            case url = "url"
            case sizeType = "sizeType"
            case width = "width"
            case height = "height"
            case tags = "tags"
        }
    }
    
    // MARK: - Video
    struct Video: Codable {
        public let url: String
        public let theme: String
        
        public enum CodingKeys: String, CodingKey {
            case url = "url"
            case theme = "theme"
        }
    }
    
    struct CustomProperty: Codable {
        public let name: String
        public let value: String
        
        public enum CodingKeys: String, CodingKey {
            case name = "name"
            case value = "value"
        }
    }
}
