import SwiftUI

struct Weather: Identifiable, Codable {
    let id = UUID()
    let weatherCondition: String
    let temperature: String
    let humidity: String
    let windSpeed: String
    
    enum CodingKeys: String, CodingKey {
        case weatherCondition
        case temperature
        case humidity
        case windSpeed
    }
}
