import SwiftUI

struct TeaGarden: Codable {
    let teaGardenID: Int
    let teaGardenName: String
    let teaGardenLocation: String
    let aiPlantingImages: ImagePair?
    let teaData: [TeaDecodeData]
}

struct ImagePair: Codable {
    let original: String
    let marked: String
}

struct TeaDecodeData: Codable {
    let area: String
    let originalImage: String
    let analyzedImage: String
    let date: String
    let weather: String
    let growth: String
    let plantingRate: String
}

class TeaService: ObservableObject {
    @Published var teaGardenData: [Tea]
    
    @AppStorage("selectedToggle") var selectedToggle: Int = 1
    
    private let baseURL: String = ""
    private let path: String = "/tea"
    
    // 在 init 中使用 self.selectedToggle 前，必須先初始化所有 Stored Property
    // 因此需先初始化 id 為空字串
    var id: String = ""
    
    // 為了讓一些 View 中的 Preview 可以使用，所以需要提供帶有可以傳入假資料參數的 init
    // 如果沒有給參數，預設為空陣列
    init(teaGardenData: [Tea] = []) {
        self.teaGardenData = teaGardenData
        self.id = "/\(self.selectedToggle)" // 每次開啟 App 時根據上次 selectedToggle 的值更新 id
    }
    
    func fetchTeaData() async throws {
        guard let url = URL(string: "\(baseURL)\(path)\(id)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let teaGardens = try JSONDecoder().decode([TeaGarden].self, from: data)
        
        // UI 更新必須在主執行緒上進行
        // 在主執行緒中更新 @Published 屬性
        DispatchQueue.main.async {
            self.teaGardenData = teaGardens.map { garden in
                Tea(
                    teaGardenID: garden.teaGardenID,
                    name: garden.teaGardenName,
                    location: garden.teaGardenLocation,
                    aiPlantingImages: garden.aiPlantingImages.map { imagePair in
                        AiPlantingImages(
                            original: imagePair.original,
                            marked: imagePair.marked
                        )
                    },
                    teaData: garden.teaData.map { decodeData in
                        TeaData(
                            area: decodeData.area,
                            originalImage: decodeData.originalImage,
                            analyzedImage: decodeData.analyzedImage,
                            date: decodeData.date,
                            weather: decodeData.weather,
                            growth: decodeData.growth,
                            plantingRate: decodeData.plantingRate
                        )
                    }
                )
            }
        }
    }
}
