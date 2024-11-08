import SwiftUI
import PhotosUI

struct LoadingView: View {
    @EnvironmentObject var historyLimitManager: HistoryLimitManager
    @Binding var isOfflineModeEnabled: Bool
    // 茶葉病害分析
    @State private var isHistoryLoading = false
    @State private var showHistoryPage: Bool = false
    @State private var isCameraLoading = false
    @State private var showOptions = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var cameraImage: UIImage? = nil
    @State private var showAnalysisPage = false
    
    @State private var offsetY: CGFloat = 0
    @State private var showProgressView: Bool = false
    
    var body: some View {
        VStack {
            Image("leaf")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .offset(y: offsetY) // 透過 y 來上移圖片
                .onAppear {
                    // 只有在非離線模式下才進行上移載入動畫
                    if !isOfflineModeEnabled {
                        // 進入 App 1 秒後上移
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                offsetY = -20 // 圖片上移
                            }
                            
                            // 延遲 0.1 秒讓 ProgressView 同步淡入
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    showProgressView = true
                                }
                            }
                        }
                    }
                }
                .onChange(of: isOfflineModeEnabled) { _, newValue in
                    if newValue {
                        // 離線模式下，讓 offsetY 回到原位並淡出 showProgressView
                        withAnimation(.easeInOut(duration: 0.5)) {
                            offsetY = 0
                            showProgressView = false
                        }
                    }
                }
            
            if showProgressView {
                ProgressView()
                    .transition(.opacity)
                    .tint(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("ThemeColor"))
        // 在離線模式下，點擊茶圖標後顯示選擇相機或相簿
        .onTapGesture {
            if isOfflineModeEnabled {
                showOptions = true
            }
        }
        .overlay {
            PhotoSelectionButton(
                showHistoryButton: .constant(true),
                isHistoryLoading: $isHistoryLoading,
                showHistoryPage: $showHistoryPage,
                isCameraLoading: $isCameraLoading,
                showOptions: $showOptions,
                showPhotoPicker: $showPhotoPicker,
                showCamera: $showCamera,
                photoPickerItem: $photoPickerItem,
                cameraImage: $cameraImage,
                onPhotoPickerItemChange: { newItem in
                    if newItem != nil {
                        showAnalysisPage = true
                    }
                },
                onSelectedImageChange: { newImage in
                    if newImage != nil {
                        showAnalysisPage = true
                    }
                }
            )
        }
        .overlay {
            // 相機關閉後，正在載入所拍攝的照片時顯示
            // 歷史分析結果頁面載入中時顯示
            if isCameraLoading || isHistoryLoading {
                ActionLoadingView()
            }
        }
        .navigationDestination(isPresented: $showAnalysisPage) {
            TeaLeafAnalysisView(photoPickerItem: photoPickerItem, cameraImage: cameraImage)
            // 重置狀態，不然使用相機後再用相簿，會都是用相機的圖片
                .onDisappear {
                    cameraImage = nil
                    photoPickerItem = nil
                }
                .environmentObject(historyLimitManager)
        }
        .navigationDestination(isPresented: $showHistoryPage) {
            TeaDiseaseHistoryView()
                .onAppear() {
                    // TeaDiseaseHistoryView 載入後，於 ContentView 關閉 ActionLoadingView
                    isHistoryLoading = false
                }
                .environmentObject(historyLimitManager)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoadingView(isOfflineModeEnabled: .constant(false))
        .environmentObject(HistoryLimitManager())
}
