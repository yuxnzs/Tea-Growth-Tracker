import SwiftUI
import MapKit
import SwiftData

struct TeaDiseaseMapView: View {
    @AppStorage("selectedToggle") var selectedToggle: Int = 1
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme // 深淺色模式切換
    @EnvironmentObject var displayManager: DisplayManager
    @State private var diseases: [TeaDisease] = []
    @State private var selectedDisease: TeaDisease?
    @State private var showDiseaseDetail = false
    @State private var overrideColorScheme: ColorScheme?
    @State private var userPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isStandardMap = false
    @State private var isPageAppear = false
    
    var body: some View {
        NavigationStack {
            Map(position: $userPosition) {
                UserAnnotation() // 於地圖上顯示使用者目前位置
                
                // 頁面顯示時才渲染 Annotation，提升性能
                if isPageAppear {
                    ForEach(diseases, id: \.id) { disease in
                        if let longitude = disease.longitude, let latitude = disease.latitude {
                            Annotation(disease.diseaseName ,coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                                // 使用縮小後的圖片進行顯示，避免圖片過大造成卡頓
                                if let resizedImage = disease.teaImage.resizeProportionally(toFit: CGSize(width: 200, height: 200)) {
                                    Image(uiImage: resizedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.green)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            displayManager.showActionLoadingView = true
                                            // 使用 Task 確保先顯示 ActionLoadingView，避免顯示詳細資訊前 UI 卡住
                                            Task { @MainActor in
                                                selectedDisease = disease
                                                withAnimation {
                                                    showDiseaseDetail = true
                                                }
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .mapControls {
                MapCompass() // 地圖指南針
                MapUserLocationButton() // 返回目前位置按鈕
                MapPitchToggle() // 切換 2D 3D 按鈕
            }
            .mapStyle(isStandardMap ? .standard(pointsOfInterest: .excludingAll) : .imagery(elevation: .realistic))
            .overlay(alignment: .bottomTrailing) {
                if !showDiseaseDetail {
                    mapButton(defaultIcon: "photo", toggledIcon: "globe", condition: isStandardMap) {
                        isStandardMap.toggle()
                    }
                    .padding(.bottom, 50)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                mapButton(defaultIcon: "moon.circle", toggledIcon: "sun.max", condition: overrideColorScheme == .light || (overrideColorScheme == nil && colorScheme == .light)) {
                    toggleColorScheme()
                }
            }
            .overlay {
                // 顯示疾病詳細資訊
                if showDiseaseDetail {
                    ZStack {
                        // 點擊背景時關閉詳細資訊
                        Color.black.opacity(0.2)
                            .onTapGesture {
                                withAnimation {
                                    showDiseaseDetail = false
                                }
                            }
                            .ignoresSafeArea()
                        
                        NavigationLink {
                            FullImageView(
                                selectedTab: .constant(0),
                                isAnalysisView: false,
                                asyncImages: nil,
                                useUIImage: true,
                                uiImage: selectedDisease!.teaImage
                            )
                        } label: {
                            VStack {
                                TeaDiseaseHistoryCardRepresentable(
                                    teaImage: selectedDisease!.teaImage,
                                    diseaseName: selectedDisease!.diseaseName,
                                    confidenceLevel: selectedDisease!.confidenceLevel,
                                    analysisDate: selectedDisease!.analysisDate
                                )
                                .frame(height: 200)
                            }
                            .onAppear {
                                displayManager.showActionLoadingView = false
                            }
                        }
                    }
                }
            }
            .onAppear {
                displayManager.showActionLoadingView = true
                
                // 使用 Task 確保不延遲、先進入地圖頁面再載入 Annotations
                Task { @MainActor in
                    isPageAppear = true
                }
                
                // 取得使用者目前位置
                CLLocationManager().requestWhenInUseAuthorization()
                
                // 切換茶園時地圖顯示位置才會改變
                if displayManager.isGardenChanged {
                    // 地圖預設顯示茶園位置
                    Task { @MainActor in
                        if let location = Config.teaGardenLocations[selectedToggle] {
                            userPosition = .region(
                                MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                                    span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                                )
                            )
                        }
                    }
                    
                    displayManager.isGardenChanged = false
                }
                
                if diseases.isEmpty || displayManager.needReloadMap {
                    diseases.removeAll()
                    // 取得疾病位置資料
                    loadDiseaseLocations()
                }
                
                Task { @MainActor in
                    displayManager.showActionLoadingView = false
                }
            }
            .onDisappear {
                isPageAppear = false
            }
            .toolbar(.hidden) // 隱藏 NavigationBar
            .preferredColorScheme(overrideColorScheme)
        }
    }
    
    // 右下角按鈕
    private func mapButton(defaultIcon: String, toggledIcon: String, condition: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: condition ? defaultIcon : toggledIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 23)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding([.trailing, .bottom], 10)
        }
    }
    
    private func toggleColorScheme() {
        // nil 表示跟隨系統模式
        // 按下按鈕後，overrideColorScheme 被設定為 .light 或 .dark，覆蓋系統模式
        // preferredColorScheme 開始以 overrideColorScheme 的值為準
        if overrideColorScheme == nil {
            overrideColorScheme = colorScheme == .light ? .dark : .light
        } else {
            overrideColorScheme = nil
        }
    }
    
    // 確保在主執行緒執行
    @MainActor
    func loadDiseaseLocations() {
        // 使用 Task 確保先進入此頁，避免進入此頁前 UI 卡住
        Task {
            do {
                var descriptor = FetchDescriptor<TeaDisease>()
                descriptor.includePendingChanges = false
                
                let teaDiseaseData = try modelContext.fetch(descriptor)
                
                for teaDisease in teaDiseaseData {
                    diseases.append(teaDisease)
                }
                
                displayManager.needReloadMap = false
                displayManager.showActionLoadingView = false
            } catch {
                print("載入資料失敗：\(error)")
            }
        }
    }
}

#Preview {
    TeaDiseaseMapView()
        .environmentObject(DisplayManager())
}
