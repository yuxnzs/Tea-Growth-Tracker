import SwiftUI

class TeaData: Identifiable, ObservableObject {
    let id = UUID()
    let teaGardenID: Int
    let name: String
    let location: String
    let originalImage: String
    let analyzedImage: String
    let date: String
    let weather: String
    let growth: String
    let waterFlow: String
    
    init(teaGardenID: Int, name: String, location: String, originalImage: String, analyzedImage: String, date: String, weather: String, growth: String, waterFlow: String) {
        self.teaGardenID = teaGardenID
        self.name = name
        self.location = location
        self.originalImage = originalImage
        self.analyzedImage = analyzedImage
        self.date = date
        self.weather = weather
        self.growth = growth
        self.waterFlow = waterFlow
    }
}
