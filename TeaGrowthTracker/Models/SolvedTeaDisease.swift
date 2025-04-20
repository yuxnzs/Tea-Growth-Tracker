import SwiftData
import UIKit

@Model
class SolvedTeaDisease {
    var id: UUID
    var createdAt: Date // 追蹤建立時間
    @Attribute(.externalStorage) var imageData: Data
    var diseaseName: String
    var confidenceLevel: Double
    var analysisDate: String
    var longitude: Double?
    var latitude: Double?
    
    // 計算屬性，存取圖片 teaImage 時將轉換成 UIImage
    @Transient var teaImage: UIImage {
        get {
            UIImage(data: imageData) ?? UIImage()
        }
        set {
            self.imageData = newValue.pngData() ?? Data()
        }
    }
    
    init(teaDisease: TeaDisease) {
        self.id = UUID()
        self.createdAt = Date()
        self.imageData = teaDisease.imageData
        self.diseaseName = teaDisease.diseaseName
        self.confidenceLevel = teaDisease.confidenceLevel
        self.analysisDate = teaDisease.analysisDate
        self.longitude = teaDisease.longitude
        self.latitude = teaDisease.latitude
    }
}
