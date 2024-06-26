import SwiftUI

class Tea: Identifiable, ObservableObject {
    let id = UUID()
    let teaGardenID: Int
    let name: String
    let location: String
    let teaData: [TeaData]
    
    init(teaGardenID: Int, name: String, location: String, teaData: [TeaData]) {
        self.teaGardenID = teaGardenID
        self.name = name
        self.location = location
        self.teaData = teaData
    }
}

class TeaData: Identifiable {
    let id: UUID = UUID()
    let area: String
    let originalImage: String
    let analyzedImage: String
    let date: String
    let weather: String
    let growth: String
    let plantingRate: String
    
    init(area: String, originalImage: String, analyzedImage: String, date: String, weather: String, growth: String, plantingRate: String) {
        self.area = area
        self.originalImage = originalImage
        self.analyzedImage = analyzedImage
        self.date = date
        self.weather = weather
        self.growth = growth
        self.plantingRate = plantingRate
    }
}
