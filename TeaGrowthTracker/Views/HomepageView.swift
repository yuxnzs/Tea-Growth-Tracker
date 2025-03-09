import SwiftUI
import PhotosUI

struct HomepageView: View {
    @StateObject var teaService = TeaService()
    @EnvironmentObject var historyLimitManager: HistoryLimitManager
    @EnvironmentObject var displayManager: DisplayManager
    var weatherService = WeatherService()
    
    // 剛開啟 App 時取得後端資料，取得完畢再顯示
    @State var isLoading: Bool = true
    @State var firstAppear: Bool = false
    
    // 天氣資料
    @State private var weatherData: Weather?
    
    // 控制 Alert 顯示
    @State private var isError: Bool = false
    
    // 離線模式
    @State private var isOfflineModeEnabled: Bool = false
    
    // 控制 Sheet 顯示
    @State private var isAnalysisViewPresented: Bool = false
    @State private var isTeaGardenSelectorViewPresented: Bool = false
    
    @State private var needsRefreshData = false
    
    // 傳遞被點擊的歷史分析結果
    @State var selectedTeaData: TeaData? = nil
    
    // 相機或相簿照片選擇
    @State private var showOptions = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var isCameraLoading = false
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var cameraImage: UIImage? = nil
    @State private var showAnalysisPage = false
    
    @State var showHistoryPage: Bool = false
    // 歷史紀錄頁面載入時顯示
    @State private var isHistoryLoading = false
    
    // 避免底部導航列遮擋內容
    let bottomPadding: CGFloat
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                // 透過 ZStack 設定頂部安全區域背景顏色，避免內容直接透過去
                ZStack(alignment: .top) {
                    // 取得資料時顯示載入中
                    if isLoading {
                        VStack {
                            LoadingView(isOfflineModeEnabled: $isOfflineModeEnabled)
                                .onAppear {
                                    // 若是離線模式就不用取得資料
                                    if !isOfflineModeEnabled {
                                        Task {
                                            await fetchTeaData()
                                        }
                                        firstAppear = true
                                    }
                                }
                                .environmentObject(historyLimitManager)
                                .environmentObject(displayManager)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            TeaGardenInfoBar(
                                teaGardenName: teaService.teaGardenData.last!.name,
                                teaGardenLocation: teaService.teaGardenData.last!.location,
                                isPlaceholder: true
                            )
                            .padding(.bottom, 7)
                            .environmentObject(teaService)
                            
                            VStack(spacing: 16) {
                                // 最近一次分析結果
                                VStack {
                                    HStack {
                                        Text("茶園即時環境數據")
                                            .font(.system(size: 25))
                                            .fontWeight(.bold)
                                    }
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    DataGrid(
                                        titles: ["天氣情況", "溫度", "濕度", "風速"],
                                        values: [
                                            "\(weatherData?.weatherCondition ?? "未知")",
                                            "\(weatherData?.temperature ?? "--") °C",
                                            "\(weatherData?.humidity ?? "--") %",
                                            "\(weatherData?.windSpeed ?? "--") m/s"
                                        ]
                                    )
                                    .padding(.horizontal, 20)
                                }
                                
                                // 歷史分析結果
                                VStack {
                                    NavigationLink {
                                        AreaListView()
                                            .environmentObject(teaService)
                                            .environmentObject(displayManager)
                                    } label: {
                                        HStack {
                                            Text("歷史分析結果")
                                                .font(.system(size: 25))
                                                .fontWeight(.bold)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "arrow.right")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .buttonStyle(.plain)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            // teaService.teaModel 是一個陣列，所以要用 flatMap 來取得一個元素
                                            // 再透過該元素取得 teaData 陣列
                                            // teaService.teaModel.compactMap 的 $0 為一個 TeaModel 物件
                                            // first 取得 A 區
                                            ForEach(teaService.teaGardenData.compactMap { $0.teaData.prefix(3).first }.reversed()) { teaData in
                                                RecentAnalysisPreview(teaData: teaData)
                                                    .padding(.trailing, 15)
                                                // 傳 teaData 的前三項分析資料給 RecentAnalysisPreview 顯示
                                                    .onTapGesture {
                                                        selectedTeaData = teaData
                                                    }
                                                // 使用 isPresented 來控制 sheet 顯示
                                                // 會因為狀態同步問題導致顯示錯誤的數據
                                                // 所以改用 item，因為 item 綁定的是具體的數據物件
                                                // item 有值時顯示
                                                    .sheet(item: $selectedTeaData) { teaData in
                                                        AnalysisView(teaData: teaData, isSheet: true)
                                                    }
                                            }
                                        }
                                        .padding(.leading, 20)
                                    }
                                }
                                .padding(.bottom, bottomPadding)
                            }
                        }
                        .onAppear {
                            // 啟動 App 進入到首頁時，不需要動畫出現底部導航列
                            if firstAppear {
                                displayManager.isShowingTabBar = true
                                firstAppear = false
                            } else {
                                withAnimation {
                                    // 當首頁出現時，顯示底部導航列
                                    displayManager.isShowingTabBar = true
                                }
                            }
                        }
                        
                        // 頂部資訊欄
                        TeaGardenInfoBar(
                            isTeaGardenSelectorViewPresented: $isTeaGardenSelectorViewPresented,
                            needsRefreshData: $needsRefreshData,
                            isHistoryLoading: $isHistoryLoading,
                            showHistoryPage: $showHistoryPage,
                            isCameraLoading: $isCameraLoading,
                            showOptions: $showOptions,
                            showPhotoPicker: $showPhotoPicker,
                            showCamera: $showCamera,
                            photoPickerItem: $photoPickerItem,
                            cameraImage: $cameraImage,
                            showAnalysisPage: $showAnalysisPage,
                            teaGardenName: teaService.teaGardenData.last!.name,
                            teaGardenLocation: teaService.teaGardenData.last!.location
                        )
                        .environmentObject(teaService)
                        .environmentObject(displayManager)
                    }
                    
                    if !isLoading {
                        Color(red: 0.098, green: 0.412, blue: 0.235)
                        // 安全區域高度，頂部顏色區塊，確保內容不會穿過瀏海
                            .frame(height: geometry.safeAreaInsets.top)
                            .ignoresSafeArea()
                    }
                }
                // 從 sheet 中的 TeaGardenSelectorView 返回時觸發
                .onChange(of: needsRefreshData) { _, newValue in
                    if newValue {
                        // 更新資料
                        Task {
                            await fetchTeaData(skipDelay: true)
                            DispatchQueue.main.async {
                                needsRefreshData = false
                            }
                        }
                    }
                }
                // 警告提示
                .alert("錯誤", isPresented: $isError) {
                    Button("重試") {
                        Task {
                            DispatchQueue.main.async {
                                isError = false
                            }
                            // 避免使用者連續點擊導致 alert 未正確顯示
                            try? await Task.sleep(for: .seconds(0.2))
                            await fetchTeaData()
                        }
                    }
                    Button("進入離線模式") {
                        isOfflineModeEnabled = true
                    }
                } message: {
                    Text("伺服器連線錯誤，請稍後再試")
                }
                // 導航到茶葉分析頁面
                .navigationDestination(isPresented: $showAnalysisPage) {
                    TeaLeafAnalysisView(photoPickerItem: photoPickerItem, cameraImage: cameraImage)
                    // 重置狀態，不然使用相機後再用相簿，會都是用相機的圖片
                        .onDisappear {
                            cameraImage = nil
                            photoPickerItem = nil
                        }
                        .environmentObject(historyLimitManager)
                        .environmentObject(displayManager)
                }
                .navigationDestination(isPresented: $showHistoryPage) {
                    TeaDiseaseHistoryView()
                        .onAppear() {
                            // TeaDiseaseHistoryView 載入後，於 ContentView 關閉 ActionLoadingView
                            isHistoryLoading = false
                        }
                        .environmentObject(historyLimitManager)
                }
                // 歷史分析結果頁面載入中時顯示
                .onChange(of: isHistoryLoading) { _, newValue in
                    if newValue {
                        displayManager.showActionLoadingView = true
                    } else {
                        displayManager.showActionLoadingView = false
                    }
                }
                // 切換茶園後，重新取得資料時顯示
                .onChange(of: needsRefreshData) { _, newValue in
                    if newValue {
                        displayManager.showActionLoadingView = true
                    } else {
                        displayManager.showActionLoadingView = false
                    }
                }
                // 相機關閉後，正在載入所拍攝的照片時顯示
                .overlay {
                    // 於 HomepageView 單獨顯示 ActionLoadingView
                    // 因為相機載入有進行特別延遲顯示處理，用全局 ActionLoadingView 會進入分析頁面後還顯示
                    if isCameraLoading {
                        ActionLoadingView()
                            .onAppear {
                                displayManager.isShowingTabBar = false
                            }
                    }
                }
                .modelContainer(for: [TeaDisease.self])
            }
        }
    }
    
    func fetchTeaData(skipDelay: Bool = false) async {
        @AppStorage("selectedToggle") var selectedToggle: Int = 1
        let startTime = Date()
        
        do {
            try await teaService.fetchTeaData()
            if let location = Config.teaGardenLocations[selectedToggle] {
                weatherData = try await weatherService.fetchHomepageWeatherData(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
            }
            let endTime = Date()
            let timeInterval = endTime.timeIntervalSince(startTime)
            
            // 如果取得資料時間小於 5 秒，繼續等待直到滿 5 秒，避免畫面快速閃爍
            if !skipDelay && timeInterval < 5 {
                let remainingTime = 5.0 - timeInterval
                try await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000)) // 等待剩餘的時間
            }
            
            DispatchQueue.main.async {
                isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                isLoading = true
                isError = true
            }
        }
    }
}

#Preview {
    HomepageView(bottomPadding: 20)
        .environmentObject(HistoryLimitManager())
        .environmentObject(DisplayManager())
}
