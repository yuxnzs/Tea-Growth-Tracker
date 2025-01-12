import SwiftData
import UIKit

@Model
class TeaDisease {
    var id: UUID
    var createdAt: Date // 追蹤建立時間
    @Attribute(.externalStorage) var imageData: Data
    var diseaseName: String
    var confidenceLevel: Double
    var analysisDate: String
    
    // 計算屬性，存取圖片 teaImage 時將轉換成 UIImage
    @Transient var teaImage: UIImage {
        get {
            UIImage(data: imageData) ?? UIImage()
        }
        set {
            self.imageData = newValue.pngData() ?? Data()
        }
    }
    
    init(teaImage: UIImage, diseaseName: String, confidenceLevel: Double) {
        self.id = UUID()
        self.createdAt = Date()
        self.imageData = teaImage.pngData() ?? Data()
        self.diseaseName = diseaseName
        self.confidenceLevel = confidenceLevel
        self.analysisDate = TeaDisease.currentDateString() // 新增資料時自動加入日期
    }
    
    // 取得目前日期的 String
    static func currentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 日期格式
        return dateFormatter.string(from: Date())
    }
}
