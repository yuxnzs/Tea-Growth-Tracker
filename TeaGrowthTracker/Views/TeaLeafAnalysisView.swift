import SwiftUI
import SwiftData
import PhotosUI
import CoreML
import ImageIO

struct TeaLeafAnalysisView: View {
    // 從 SwiftData 取得儲存的茶葉分析資料
    @Environment(\.modelContext) var modelContext
    
    @EnvironmentObject var historyLimitManager: HistoryLimitManager
    @EnvironmentObject var displayManager: DisplayManager
    
    @StateObject private var locationManager = LocationManager()
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    @State private var isFetchingLocation = false
    @State private var showFetchingLocationAlert = false
    @State private var isLocationFetchSuccessful = false
    
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
    
    @State private var hasSavedOnce = false
    @State private var hasSavedSuccessfully = false
    @State private var hasSavedError = false
    @State private var hasReachedLimit = false
    @State private var showActionLoading = false
    
    let containerWidth = UIScreen.main.bounds.width - 40
    // 病害類別名稱，用來對照模型結果
    let classNames = ["炭疽病", "藻斑病", "鳥眼斑病", "赤葉枯病", "灰斑病", "健康", "紅葉斑病", "白斑病"]
    
    init(photoPickerItem: PhotosPickerItem?, cameraImage: UIImage?) {
        self._photoPickerItem = State(initialValue: photoPickerItem)
        self._cameraImage = State(initialValue: cameraImage)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 茶葉圖片
                UserTeaImage(loadedImage: loadedImage)
                
                ScrollView {
                    // 分析結果與按鈕
                    VStack(spacing: 0) {
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
                        
                        Spacer() // 推開分析結果跟按鈕
                        
                        Button {
                            if historyLimitManager.hasReachedLimit() {
                                hasReachedLimit = true
                                return
                            }
                            
                            if isFetchingLocation {
                                showFetchingLocationAlert = true
                                return
                            }
                            
                            showActionLoading = true
                            
                            // 避免阻塞主線程導致畫面卡頓
                            DispatchQueue.global().async {
                                if let loadedImage = loadedImage, let predictionResult = predictionResult, let confidence = confidence {
                                    let newDisease = TeaDisease(teaImage: loadedImage, diseaseName: predictionResult, confidenceLevel: confidence, longitude: longitude, latitude: latitude)
                                    DispatchQueue.main.async {
                                        do {
                                            modelContext.insert(newDisease)
                                            try modelContext.save()
                                            
                                            // 儲存成功
                                            hasSavedOnce = true
                                            hasSavedSuccessfully = true
                                            
                                            // 更新紀錄數量與通知歷史頁面更新
                                            historyLimitManager.incrementCount()
                                            displayManager.hasNewDiseaseData = true
                                            // 通知地圖更新
                                            displayManager.needReloadMap = true
                                        } catch {
                                            DispatchQueue.main.async {
                                                hasSavedError = true
                                            }
                                        }
                                    }
                                }
                                DispatchQueue.main.async {
                                    showActionLoading = false
                                }
                            }
                            
                        } label: {
                            ActionButton(
                                title: "儲存此次分析",
                                buttonWidth: containerWidth,
                                backgroundColor: Color(red: 0.098, green: 0.412, blue: 0.235),
                                foregroundColor: .white
                            )
                        }
                        .disabled(isLoading || isImageError || isResultError || hasSavedOnce)
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
                    .frame(height: UIScreen.main.bounds.height - 380) // 螢幕高度 - 圖片高度 + 一點底部間距
                }
                .onAppear {
                    loadImageFromUser()
                }
                .alert(isPresented: $showFetchingLocationAlert) {
                    Alert(
                        title: Text("正在取得位置資訊"),
                        message: Text("請稍候再試，完成後將顯示於病害地圖"),
                        dismissButton: .default(Text("確定"))
                    )
                }
                .alert(
                    isLocationFetchSuccessful 
                    ? "分析結果已儲存\n已同步至病害地圖"
                    : "分析結果已儲存",
                    isPresented: $hasSavedSuccessfully) {
                        Button("確定") {
                            hasSavedSuccessfully = false
                        }
                    }
                    .alert("分析結果儲存錯誤，請再試一次", isPresented: $hasSavedError) {
                        Button("確定") {
                            hasSavedError = false
                        }
                    }
                    .alert("已達儲存上限，請刪除部分紀錄後再試一次", isPresented: $hasReachedLimit) {
                        Button("關閉") {
                            hasReachedLimit = false
                        }
                        NavigationLink {
                            TeaDiseaseHistoryView(needReloadData: true)
                                .environmentObject(historyLimitManager)
                        } label: {
                            Text("前往紀錄頁面")
                        }
                    }
            }
            .overlay {
                PhotoSelectionButton(
                    showHistoryButton: .constant(false), // TeaLeafAnalysisView 不會顯示歷史按鈕
                    isHistoryLoading: .constant(false), // TeaLeafAnalysisView 不會使用到此狀態
                    showHistoryPage: .constant(false), // TeaLeafAnalysisView 不會使用到此狀態
                    isCameraLoading: $isCameraLoading, // TeaLeafAnalysisView 不會使用到此狀態
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
                .environmentObject(displayManager)
            }
            .onChange(of: showActionLoading) { _, newValue in
                if newValue {
                    displayManager.showActionLoadingView = true
                } else {
                    displayManager.showActionLoadingView = false
                }
            }
            .onAppear {
                withAnimation {
                    displayManager.isShowingTabBar = false
                }
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
        hasSavedOnce = false
        hasSavedSuccessfully = false
        hasSavedError = false
        hasReachedLimit = false
        isFetchingLocation = false
        showFetchingLocationAlert = false
        isLocationFetchSuccessful = false
    }
    
    func loadImageFromUser() {
        if let image = cameraImage {
            isFetchingLocation = true
            // 設置位置更新的 closure
            locationManager.onLocationUpdate = { location in
                if let location = location {
                    // 更新位置
                    latitude = location.coordinate.latitude
                    longitude = location.coordinate.longitude
                    isFetchingLocation = false
                    isLocationFetchSuccessful = true
                } else {
                    print("無法取得位置")
                    // 避免位置為 nil 時，繼續使用上次的位置
                    longitude = nil
                    latitude = nil
                    isFetchingLocation = false
                    isLocationFetchSuccessful = false
                }
            }
            
            // 請求位置，於 didUpdateLocations 內更新位置
            locationManager.requestLocation()
            
            // 如果有 UIImage（來自相機），直接使用
            DispatchQueue.main.async {
                loadedImage = image
            }
            runModelTest(image: image)
            DispatchQueue.main.async {
                isLoading = false
            }
        } else if let photoPickerItem = photoPickerItem {
            isFetchingLocation = true
            // 從 photoPickerItem 載入圖片
            Task {
                if let data = try? await photoPickerItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    // 解析 EXIF (包含 GPS)
                    if let gpsInfo = extractGPSInfo(from: data) {
                        latitude = gpsInfo.latitude
                        longitude = gpsInfo.longitude
                        isFetchingLocation = false
                        isLocationFetchSuccessful = true
                    } else {
                        print("沒有 GPS EXIF 或解析失敗")
                        // 避免位置為 nil 時，繼續使用上次的位置
                        longitude = nil
                        latitude = nil
                        isFetchingLocation = false
                        isLocationFetchSuccessful = false
                    }
                    
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
    
    // 從圖片 Data 解析出 GPS 經緯度資訊
    func extractGPSInfo(from imageData: Data) -> (latitude: Double, longitude: Double)? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            return nil
        }
        
        // kCGImagePropertyGPSDictionary 是一個字典，裡面包含經度/緯度等
        if let gpsDict = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            if let lat = gpsDict[kCGImagePropertyGPSLatitude as String] as? Double,
               let lon = gpsDict[kCGImagePropertyGPSLongitude as String] as? Double {
                // 有些照片還會記載 GPSLatitudeRef / GPSLongitudeRef (N / S / E / W)
                // 可能需要根據 Ref 轉換正負號
                var finalLat = lat
                var finalLon = lon
                
                // 如果有參考方向，就進行 N/S/E/W 處理
                if let latRef = gpsDict[kCGImagePropertyGPSLatitudeRef as String] as? String,
                   latRef.uppercased() == "S" {
                    finalLat = -finalLat
                }
                if let lonRef = gpsDict[kCGImagePropertyGPSLongitudeRef as String] as? String,
                   lonRef.uppercased() == "W" {
                    finalLon = -finalLon
                }
                
                return (latitude: finalLat, longitude: finalLon)
            }
        }
        return nil
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
        .environmentObject(HistoryLimitManager())
        .environmentObject(DisplayManager())
}
