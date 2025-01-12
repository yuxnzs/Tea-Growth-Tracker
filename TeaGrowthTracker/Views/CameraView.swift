import SwiftUI
import UIKit

// 使用 UIKit 相機功能
struct CameraView: UIViewControllerRepresentable {
    @EnvironmentObject var displayManager: DisplayManager
    @Binding var image: UIImage?
    @Binding var isCameraLoading: Bool
    
    let showTabBarOnCameraCancel: Bool
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.modalPresentationStyle = .fullScreen
        // 開啟相機時背景先顯示載入中，避免在關閉相機時才更新 isCameraLoading = true 會因 DispatchQueue.main.async 導致延遲顯示
        // 延遲 0.5 秒，避免一點開相機使用者就看到黑背景
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isCameraLoading = true
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // 先關閉相機再處理圖片，避免使用者按下確認後，卡在相機畫面等待圖片被處理
                picker.dismiss(animated: true)
                DispatchQueue.main.async {
                    self.parent.image = image
                    // 延遲一點時間，避免視覺上載入中提早消失
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.parent.isCameraLoading = false
                    }
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async {
                self.parent.isCameraLoading = false
                // 於首頁開啟相機並取消時，顯示 TabBar
                if self.parent.showTabBarOnCameraCancel {
                    withAnimation {
                        self.parent.displayManager.isShowingTabBar = true
                    }
                }
            }
            picker.dismiss(animated: true)
        }
    }
}
