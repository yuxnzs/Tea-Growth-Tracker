import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject var teaService = TeaService()
    // 剛開啟 App 時取得後端資料，取得完畢再顯示
    @State var isLoading: Bool = true
    
    // 控制 Alert 顯示
    @State private var showAlert: Bool = false
    
    // 控制 Sheet 顯示
    @State private var isAnalysisViewPresented: Bool = false
    @State private var isToggleSearchViewPresented: Bool = false
    
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
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                // 透過 ZStack 設定頂部安全區域背景顏色，避免內容直接透過去
                ZStack(alignment: .top) {
                    // 取得資料時顯示載入中
                    if isLoading {
                        VStack {
                            LoadingView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // 取得最近一次資料
                        if let latestTeaData = teaService.teaGardenData.last?.teaData.first {
                            ScrollView {
                                VStack(spacing: 25) {
                                    // 頂部資訊欄
                                    HStack {
                                        // 文字資訊
                                        VStack(spacing: 20) {
                                            // 茶園名稱
                                            HStack {
                                                Image("pin")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundStyle(.white)
                                                    .padding(.trailing, 3)
                                                    .padding(.leading, -3)
                                                
                                                Text(teaService.teaGardenData.last!.name)
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(.white)
                                                // 點擊茶園名稱切換茶園
                                                    .onTapGesture {
                                                        isToggleSearchViewPresented.toggle()
                                                    }
                                                    .sheet(isPresented: $isToggleSearchViewPresented, onDismiss: {
                                                        // 關閉時，獲取新的茶園資料
                                                        needsRefreshData = true
                                                    }) {
                                                        TeaGardenSelectorView()
                                                            .environmentObject(teaService)
                                                            .presentationDetents([.fraction(0.5)])
                                                    }
                                                
                                                Spacer()
                                            }
                                            
                                            // 茶園位置
                                            HStack {
                                                Image(systemName: "location.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundStyle(.white)
                                                    .padding(.trailing, 3)
                                                
                                                Text(teaService.teaGardenData.last!.location)
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(.white)
                                                
                                                Spacer()
                                            }
                                        }
                                        // 茶圖標
                                        VStack {
                                            Image("leaf")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 65, height: 65)
                                        }
                                        // 點擊茶圖標後顯示選擇相機或相簿
                                        .onTapGesture {
                                            showOptions = true
                                        }
                                        .overlay {
                                            PhotoSelectionButton(
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
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 20)
                                    .padding(.bottom)
                                    .padding(.horizontal)
                                    .background(Color(red: 0.098, green: 0.412, blue: 0.235)) // #19693c
                                    // 切底部圓角
                                    .clipShape(UnevenRoundedRectangle(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: 25,
                                        bottomTrailingRadius: 25,
                                        topTrailingRadius: 0
                                    ))
                                    
                                    // 最近一次分析結果
                                    VStack {
                                        NavigationLink {
                                            AnalysisView(teaData: latestTeaData)
                                        } label: {
                                            HStack {
                                                Text("最近一次分析結果")
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
                                        // 去除 NavigationLink label 內的藍色
                                        .buttonStyle(.plain)
                                        
                                        DataGrid(teaData: latestTeaData)
                                            .padding(.horizontal, 10)
                                    }
                                    
                                    // 歷史分析結果
                                    VStack {
                                        NavigationLink {
                                            AreaListView()
                                                .environmentObject(teaService)
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
                                }
                            }
                        }
                    }
                    
                    if !isLoading {
                        Color(red: 0.098, green: 0.412, blue: 0.235)
                        // 安全區域高度，頂部顏色區塊，確保內容不會穿過瀏海
                            .frame(height: geometry.safeAreaInsets.top)
                            .ignoresSafeArea()
                    }
                }
                .onAppear {
                    Task {
                        await fetchTeaData()
                    }
                }
                // 從 sheet 中的 ToggleSearchView 返回時觸發
                .onChange(of: needsRefreshData) { newValue in
                    if newValue {
                        // 更新資料
                        Task {
                            await fetchTeaData()
                            needsRefreshData = false
                        }
                    }
                }
                // 警告提示
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("錯誤"),
                          message: Text("伺服器錯誤，請稍後再試。"),
                          dismissButton: .default(Text("OK"))
                    )
                }
                // 導航到茶葉分析頁面
                .navigationDestination(isPresented: $showAnalysisPage) {
                    TeaLeafAnalysisView(photoPickerItem: photoPickerItem, cameraImage: cameraImage)
                    // 重置狀態，不然使用相機後再用相簿，會都是用相機的圖片
                        .onDisappear {
                            cameraImage = nil
                            photoPickerItem = nil
                        }
                }
                .overlay {
                    // 相機關閉後，正在載入所拍攝的照片時顯示
                    if isCameraLoading {
                        ZStack {
                            Color.black.opacity(0.5)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            ProgressView()
                        }
                        .ignoresSafeArea()
                    }
                }
            }
        }
    }
    
    func fetchTeaData() async {
        do {
            try await teaService.fetchTeaData()
            isLoading = false
        } catch {
            print("Error: \(error)")
            showAlert = true
        }
    }
}

#Preview {
    ContentView()
}
