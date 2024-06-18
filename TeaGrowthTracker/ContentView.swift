import SwiftUI

struct ContentView: View {
    @StateObject var teaService = TeaService()
    // 剛開啟 App 時取得後端資料，取得完畢再顯示
    @State var isLoading: Bool = true
    
    // 控制 Alert 顯示
    @State private var showAlert: Bool = false
    
    // 控制 Sheet 顯示
    @State private var isAnalysisViewPresented: Bool = false
    // 傳遞被點擊的歷史分析結果
    @State var selectedTeaData: TeaModel? = nil
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                // 透過 ZStack 設定頂部安全區域背景顏色，避免內容直接透過去
                ZStack(alignment: .top) {
                    // 取得資料時顯示載入中
                    if isLoading {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .padding(.top, 100)
                            
                            Text("載入中...")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top, 25)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        // 取得最近一次資料
                        if let latestTeaData = teaService.teaModel.last {
                            ScrollView {
                                VStack(spacing: 35) {
                                    // 頂部資訊欄
                                    HStack {
                                        // 文字資訊
                                        VStack(spacing: 20) {
                                            // 茶園名稱
                                            HStack {
                                                Image(systemName: "mappin.and.ellipse")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundStyle(.white)
                                                    .padding(.trailing, 3)
                                                
                                                Text(latestTeaData.name)
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(.white)
                                                
                                                Spacer()
                                            }
                                            
                                            // 茶園位置
                                            HStack {
                                                Image(systemName: "location")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundStyle(.white)
                                                    .padding(.trailing, 3)
                                                
                                                Text(latestTeaData.location)
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
                                            AnalysisView()
                                                .environmentObject(latestTeaData)
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
                                        
                                        DataGrid()
                                            .environmentObject(latestTeaData)
                                    }
                                    
                                    // 歷史分析結果
                                    VStack {
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
                                        .padding(.horizontal, 20)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(0..<3) { index in
                                                    RecentAnalysisPreview()
                                                        .padding(.trailing, 15)
                                                    // 傳 teaData 的前三項分析資料給 RecentAnalysisPreview 顯示
                                                        .environmentObject(teaService.teaModel[index])
                                                        .onTapGesture {
                                                            selectedTeaData = teaService.teaModel[index]
                                                        }
                                                    // 使用 isPresented 來控制 sheet 顯示
                                                    // 會因為狀態同步問題導致顯示錯誤的數據
                                                    // 所以改用 item，因為 item 綁定的是具體的數據物件
                                                    // item 有值時顯示
                                                        .sheet(item: $selectedTeaData) { teaData in
                                                            AnalysisView(isSheet: true)
                                                                .environmentObject(teaData)
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
                        await fetchTeaInfo()
                    }
                }
                // 警告提示
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("錯誤"),
                          message: Text("伺服器錯誤，請稍後再試。"),
                          dismissButton: .default(Text("OK"))
                    )
                }
                
            }
        }
    }
    
    func fetchTeaInfo() async {
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
