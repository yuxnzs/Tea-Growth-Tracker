import SwiftUI
import PhotosUI

struct PhotoSelectionButton: View {
    @Binding var isCameraLoading: Bool
    @Binding var showOptions: Bool
    @Binding var showPhotoPicker: Bool
    @Binding var showCamera: Bool
    @Binding var photoPickerItem: PhotosPickerItem?
    @Binding var cameraImage: UIImage?
    var onPhotoPickerItemChange: (PhotosPickerItem?) -> Void
    var onSelectedImageChange: (UIImage?) -> Void
    
    var body: some View {
        EmptyView()
            .confirmationDialog("選擇來源", isPresented: $showOptions, titleVisibility: .visible) {
                Button("相簿") {
                    showPhotoPicker = true
                }
                Button("相機") {
                    showCamera = true
                }
                Button("取消", role: .cancel) { }
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $photoPickerItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: photoPickerItem) { _, newItem in
                onPhotoPickerItemChange(newItem) // 將選擇的照片傳給外部，通知外部已選擇照片
                showPhotoPicker = false // 關閉照片選擇器
            }
            .onChange(of: cameraImage) { _, newImage in
                onSelectedImageChange(newImage) // 將拍攝的照片傳給外部，通知外部已拍攝照片
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(image: $cameraImage, isCameraLoading: $isCameraLoading)
                    .ignoresSafeArea()
            }
    }
}

#Preview {
    PhotoSelectionButton(
        isCameraLoading: .constant(false),
        showOptions: .constant(false),
        showPhotoPicker: .constant(false),
        showCamera: .constant(false),
        photoPickerItem: .constant(nil),
        cameraImage: .constant(nil),
        onPhotoPickerItemChange: { _ in },
        onSelectedImageChange: { _ in }
    )
}
