import Foundation

public extension Model.GetChain {
    
    struct Response: Codable, Hashable {
        public let countries: [Country]
        public let storeUnits: [StoreUnit]

        enum CodingKeys: String, CodingKey {
            case countries = "countries"
            case storeUnits = "storeUnits"
        }
    }

    // MARK: - Country
    struct Country: Codable, Hashable {
        public let id: Int
        public let name: String
        public let isoAlpha2: String
        public let currency: Currency

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case isoAlpha2 = "isoAlpha2"
            case currency = "currency"
        }
    }

    // MARK: - Currency
    struct Currency: Codable, Hashable {
        public let id: Int
        public let isoCode: Int
        public let isoAlpha3: String

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case isoCode = "isoCode"
            case isoAlpha3 = "isoAlpha3"
        }
    }

    // MARK: - StoreUnit
    struct StoreUnit: Codable, Hashable {
        public let id: String
        public let code: Int
        public let countryID: Int
        public let cityID: String
        public let organizationID: String
        public let name: String
        public let alias: String
        public let type: String
        public let status: Status
        public let address: Address
        public let coordinates: Coordinates
        public let utcOffset: String
        public let orientation: String
        public let orderTypes: [String]
        public let schedule: Schedule
        public let images: [Link]

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case code = "code"
            case countryID = "countryId"
            case cityID = "cityId"
            case organizationID = "organizationId"
            case name = "name"
            case alias = "alias"
            case type = "type"
            case status = "status"
            case address = "address"
            case coordinates = "coordinates"
            case utcOffset = "utcOffset"
            case orientation = "orientation"
            case orderTypes = "orderTypes"
            case schedule = "schedule"
            case images = "images"
        }
    }
    
    // MARK: - Link
    struct Link: Codable, Hashable {
        public let url: String

        enum CodingKeys: String, CodingKey {
            case url = "url"
        }
    }
    
    // MARK: - Address
    struct Address: Codable, Hashable {
        public let text: String?
        public let cityName: String
        public let streetName: String?
        public let streetType: String?
        public let houseNumber: String?

        enum CodingKeys: String, CodingKey {
            case text = "text"
            case cityName = "cityName"
            case streetName = "streetName"
            case streetType = "streetType"
            case houseNumber = "houseNumber"
        }
    }

    // MARK: - Coordinates
    struct Coordinates: Codable, Hashable {
        public let latitude: Double
        public let longitude: Double

        enum CodingKeys: String, CodingKey {
            case latitude = "latitude"
            case longitude = "longitude"
        }
    }

    // MARK: - Schedule
    struct Schedule: Codable, Hashable {
        public let days: [DayElement]

        enum CodingKeys: String, CodingKey {
            case days = "days"
        }
    }
    
    // MARK: - DayElement
    struct DayElement: Codable, Hashable {
        public let day: DayEnum
        public let period: Period?

        enum CodingKeys: String, CodingKey {
            case day = "day"
            case period = "period"
        }
    }

    enum DayEnum: String, Codable {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }

    // MARK: - Period
    struct Period: Codable, Hashable {
        public let start: Time
        public let end: Time

        enum CodingKeys: String, CodingKey {
            case start = "start"
            case end = "end"
        }
    }

    // MARK: - Time
    struct Time: Codable, Hashable {
        public let hour: Int
        public let minute: Int

        enum CodingKeys: String, CodingKey {
            case hour = "hour"
            case minute = "minute"
        }
    }

    enum Status: String, Codable {
        case opened = "Opened"
        case closed = "Closed"
    }
}
