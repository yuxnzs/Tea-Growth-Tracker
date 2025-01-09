import SwiftUI

struct TeaDiseaseHistoryCardRepresentable: UIViewControllerRepresentable {
    let teaImage: UIImage
    let diseaseName: String
    let confidenceLevel: Double
    let analysisDate: String
    
    func makeUIViewController(context: Context) -> TeaDiseaseHistoryCardViewController {
        let viewController = TeaDiseaseHistoryCardViewController(
            teaImage: teaImage,
            diseaseName: diseaseName,
            confidenceLevel: confidenceLevel,
            analysisDate: analysisDate
        )
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: TeaDiseaseHistoryCardViewController, context: Context) { }
}
