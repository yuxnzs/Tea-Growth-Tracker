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
    @Published var teaModel: [TeaModel] = []
    
    // 如果沒有給參數，預設為空陣列
    init(teaModel: [TeaModel] = []) {
        self.teaModel = teaModel
    }
    
    private let baseURL: String = ""
    private let path: String = "/tea"
    private let id: String = "/1"
    
    func fetchTeaData() async throws {
        guard let url = URL(string: "\(baseURL)\(path)\(id)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let teaGardens = try JSONDecoder().decode([TeaGarden].self, from: data)
        
        // UI 更新必須在主執行緒上進行
        // 在主執行緒中更新 @Published 屬性
        DispatchQueue.main.async {
            self.teaModel = teaGardens.map { garden in
                TeaModel(
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
