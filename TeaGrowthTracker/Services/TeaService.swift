import SwiftUI

struct TeaGarden: Codable {
    let teaGardenID: Int
    let teaGardenName: String
    let teaGardenLocation: String
    let originalImage: String
    let analyzedImage: String
    let date: String
    let weather: String
    let growth: String
    let waterFlow: String
}

class TeaService: ObservableObject {
    @Published var teaData: [TeaData] = []
    
    // 如果沒有給參數，預設為空陣列
    init(teaData: [TeaData] = []) {
        self.teaData = teaData
    }
    
    private let baseURL: String = ""
    private let path: String = "/tea"
    
    func fetchTeaData() async throws {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let teaGardens = try JSONDecoder().decode([TeaGarden].self, from: data)
        
        // UI 更新必須在主執行緒上進行
        // 在主執行緒中更新 @Published 屬性
        DispatchQueue.main.async {
            self.teaData = teaGardens.map { garden in
                TeaData(
                    teaGardenID: garden.teaGardenID,
                    name: garden.teaGardenName,
                    location: garden.teaGardenLocation,
                    originalImage: garden.originalImage,
                    analyzedImage: garden.analyzedImage,
                    date: garden.date,
                    weather: garden.weather,
                    growth: garden.growth,
                    waterFlow: garden.waterFlow
                )
            }
        }
    }
}
