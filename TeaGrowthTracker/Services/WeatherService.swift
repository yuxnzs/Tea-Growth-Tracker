import Foundation

struct WeatherService {
    private let baseURL: String = Config.baseURL

    func fetchHomepageWeatherData(latitude: Double, longitude: Double) async throws -> Weather {
        guard let url = URL(string: "\(baseURL)/homepage-weather/\(latitude)/\(longitude)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let weatherData = try JSONDecoder().decode(Weather.self, from: data)
        return weatherData
    }
}
