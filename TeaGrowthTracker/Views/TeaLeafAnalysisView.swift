import SwiftUI
import PhotosUI
import CoreML

struct TeaLeafAnalysisView: View {
    @State private var predictionResult: String? = nil
    @State private var confidence: Double? = nil
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    @State private var isImageError = false
    @State private var isResultError = false
    
    @State private var showOptions = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var isCameraLoading = false
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var cameraImage: UIImage?
    
    let containerWidth = UIScreen.main.bounds.width - 40
    // 病害類別名稱，用來對照模型結果
    let classNames = ["炭疽病", "藻斑病", "鳥眼斑病", "赤葉枯病", "灰斑病", "健康", "紅葉斑病", "白斑病"]
    
    init(photoPickerItem: PhotosPickerItem?, cameraImage: UIImage?) {
        self._photoPickerItem = State(initialValue: photoPickerItem)
        self._cameraImage = State(initialValue: cameraImage)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    UserTeaImage(loadedImage: loadedImage)
                    
                    Text("茶葉分析結果")
                        .frame(width: containerWidth, alignment: .leading)
                        .font(.system(size: 25, weight: .bold))
                        .padding(.vertical, 14)
                    
                    TeaLeafInfoRow(
                        isImageError: isImageError,
                        isResultError: isResultError,
                        iconName: "info.circle",
                        title: "預測病害",
                        content: predictionResult,
                        containerWidth: containerWidth
                    )
                    
                    // 有錯誤就不顯示
                    if !isImageError && !isResultError {
                        TeaLeafInfoRow(
                            isImageError: isImageError,
                            isResultError: isResultError,
                            iconName: "waveform.path.ecg",
                            title: "信心程度",
                            content: confidence.map { "\(String(format: "%.2f", $0))%" },
                            containerWidth: containerWidth
                        )
                    } else {
                        // AiTeaLeafInfoRow 高度 + Padding
                        Spacer()
                            .frame(height: 60)
                    }
                    
                    Spacer().frame(height: 170)
                    
                    Button {
                        
                    } label: {
                        ActionButton(
                            title: "儲存此次分析",
                            buttonWidth: containerWidth,
                            backgroundColor: Color(red: 0.098, green: 0.412, blue: 0.235),
                            foregroundColor: .white
                        )
                    }
                    .disabled(isLoading || isImageError || isResultError)
                    .padding(.bottom, 10)
                    
                    Button {
                        showOptions = true
                    } label: {
                        ActionButton(
                            title: "重新進行分析",
                            buttonWidth: containerWidth,
                            backgroundColor: .gray.opacity(0.3),
                            foregroundColor: .black
                        )
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                loadImageFromUser()
            }
            .overlay {
                PhotoSelectionButton(
                    isCameraLoading: $isCameraLoading, // AnalysisView 不會使用到 isCameraLoading
                    showOptions: $showOptions,
                    showPhotoPicker: $showPhotoPicker,
                    showCamera: $showCamera,
                    photoPickerItem: $photoPickerItem,
                    cameraImage: $cameraImage,
                    onPhotoPickerItemChange: { newItem in
                        if newItem != nil {
                            cameraImage = nil
                            resetAnalysisState()
                            loadImageFromUser()
                        }
                    },
                    onSelectedImageChange: { newImage in
                        if newImage != nil {
                            photoPickerItem = nil
                            resetAnalysisState()
                            loadImageFromUser()
                        }
                    }
                )
                .frame(width: 0, height: 0) // 隱藏組件
            }
            .ignoresSafeArea()
        }
    }
    
    func resetAnalysisState() {
        predictionResult = nil
        confidence = nil
        loadedImage = nil
        isLoading = true
        isImageError = false
        isResultError = false
    }
    
    func loadImageFromUser() {
        if let image = cameraImage {
            // 如果有直接的 UIImage（來自相機），直接使用
            DispatchQueue.main.async {
                loadedImage = image
            }
            runModelTest(image: image)
            DispatchQueue.main.async {
                isLoading = false
            }
        } else if let photoPickerItem = photoPickerItem {
            // 從 photoPickerItem 載入圖片
            Task {
                if let data = try? await photoPickerItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        loadedImage = uiImage
                    }
                    runModelTest(image: uiImage)
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        predictionResult = "無法載入圖片"
                        isImageError = true
                        isLoading = false
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                predictionResult = "未選擇圖片"
                isImageError = true
                isLoading = false
            }
        }
    }
    
    func runModelTest(image: UIImage) {
        guard let model = try? TeaDiseaseClassifier() else {
            DispatchQueue.main.async {
                isResultError = true
                isLoading = false
            }
            return
        }
        
        // 將選擇的圖片轉換為 MLMultiArray
        guard let resizedImage = image.resize(to: CGSize(width: 224, height: 224)),
              let mlArray = resizedImage.toMLMultiArray() else {
            DispatchQueue.main.async {
                isImageError = true
                isLoading = false
            }
            return
        }
        
        // 使用模型進行預測
        do {
            //            try throwError()
            let prediction = try model.prediction(inputs: mlArray)
            let outputArray = prediction.Identity // 模型的輸出結果 (1x8 matrix)
            
            // 將輸出轉換為 Float32 陣列
            let outputPointer = UnsafeMutablePointer<Float32>(mutating: outputArray.dataPointer.assumingMemoryBound(to: Float32.self))
            let output = Array(UnsafeBufferPointer(start: outputPointer, count: outputArray.count))
            
            // 找到最大值和對應的類別 index
            if let maxConfidence = output.max(), let predictedIndex = output.firstIndex(of: maxConfidence) {
                let predictedDisease = classNames[predictedIndex]
                DispatchQueue.main.async {
                    predictionResult = predictedDisease
                    confidence = Double(maxConfidence) * 100
                }
            }
        } catch {
            DispatchQueue.main.async {
                isResultError = true
                isLoading = false
            }
        }
    }
}

// UIImage 的擴展，用於調整大小和轉換為 MLMultiArray
extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func resizeProportionally(toFit targetFrame: CGSize) -> UIImage? {
        // 計算圖片相對於框架的寬高比例
        let widthRatio = targetFrame.width / self.size.width
        let heightRatio = targetFrame.height / self.size.height
        let scaleFactor = min(widthRatio, heightRatio) // 選擇最小比例，避免超出框架
        
        // 根據比例計算等比例縮放後的大小
        let newSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)
        
        // 繪製縮放後的圖片
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func toMLMultiArray() -> MLMultiArray? {
        guard let cgImage = self.cgImage else { return nil }
        
        // 1 x 224 x 224 x 3 的 MLMultiArray
        let width = 224
        let height = 224
        let dimensions = [1, height, width, 3] // 批次大小為 1，224x224 的大小，3 個通道（RGB）
        guard let array = try? MLMultiArray(shape: dimensions as [NSNumber], dataType: .float32) else {
            return nil
        }
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4 * width,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelBuffer = context.data else { return nil }
        let pixels = pixelBuffer.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        var pixelIndex = 0
        for y in 0..<height {
            for x in 0..<width {
                let r = Float(pixels[pixelIndex]) / 255.0
                let g = Float(pixels[pixelIndex + 1]) / 255.0
                let b = Float(pixels[pixelIndex + 2]) / 255.0
                
                // 將數據存入陣列的正確維度
                array[[0, y, x, 0] as [NSNumber]] = NSNumber(value: r)
                array[[0, y, x, 1] as [NSNumber]] = NSNumber(value: g)
                array[[0, y, x, 2] as [NSNumber]] = NSNumber(value: b)
                
                pixelIndex += 4 // 移到下一個像素（每個像素有4個值：R, G, B, 透明度）
            }
        }
        
        return array
    }
}

#Preview {
    TeaLeafAnalysisView(photoPickerItem: nil, cameraImage: UIImage(named: "test_brown"))
}
