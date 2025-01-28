import SwiftUI
import SwiftData

struct TeaDiseaseHistoryView: View {
    // 從 SwiftData 取得儲存的茶葉分析資料
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var historyLimitManager: HistoryLimitManager
    @EnvironmentObject var displayManager: DisplayManager
    
    @State private var diseases: [TeaDisease] = []
    @State private var isLoadingMoreData = false
    
    @State private var showDeleteAlert = false
    @State private var deleteError = false
    @State private var selectedDisease: TeaDisease? // 暫存選中要刪除的 disease
    @State private var selectedDiseaseIndex: Int?
    
    // 病害分析頁面離開後，透過底部導航列再進入時需重載資料
    let needReloadData: Bool
    
    let showTabBar: Bool
    // 避免底部導航列遮擋內容
    let bottomPadding: CGFloat
    
    // 離線模式不需要傳入參數
    init(bottomPadding: CGFloat = 10, showTabBar: Bool = false, needReloadData: Bool = false) {
        self.bottomPadding = bottomPadding
        self.showTabBar = showTabBar
        self.needReloadData = needReloadData
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // 沒有資料
                if historyLimitManager.currentHistoryCount == 0 {
                    VStack {
                        Spacer().frame(height: 40)
                        Text("目前沒有分析紀錄")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                }
                // 有資料但還在載入
                else if diseases.isEmpty {
                    historyLimitRow()
                    
                    ForEach(0..<5) { _ in
                        TeaDiseaseHistoryCardPlaceholder()
                            .padding(.bottom, 10)
                    }
                } else {
                    // 目前儲存的紀錄數量和上限
                    historyLimitRow()
                    
                    VStack {
                        ForEach(Array(diseases.enumerated()), id: \.element.id) { index, disease in
                            NavigationLink {
                                FullImageView(
                                    selectedTab: .constant(0),
                                    isAnalysisView: false,
                                    asyncImages: nil,
                                    useUIImage: true,
                                    uiImage: disease.teaImage
                                )
                            } label: {
                                TeaDiseaseHistoryCardRepresentable(
                                    teaImage: disease.teaImage,
                                    diseaseName: disease.diseaseName,
                                    confidenceLevel: disease.confidenceLevel,
                                    analysisDate: disease.analysisDate
                                )
                                .padding(.bottom, 210)
                                // UIKit 內按鈕無法在此點擊，因此用 .overlay 添加右上角刪除按鈕
                                .overlay(alignment: .topTrailing) {
                                    Button(action: {
                                        DispatchQueue.main.async {
                                            selectedDisease = disease
                                            selectedDiseaseIndex = index
                                            showDeleteAlert = true
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .padding(7)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .padding(.trailing, 28) // 外距 20 + 內距 8
                                    .padding(.top, 8)
                                }
                            }
                        }
                        
                        if isLoadingMoreData {
                            ProgressView()
                                .padding(.top, 20)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, bottomPadding)
                    
                    // 使用 LazyVStack + Color.clear 來偵測是否滑到最底部
                    LazyVStack {
                        Color.clear
                            .onAppear {
                                // 如果目前顯示的紀錄數量不等於上限，且不是正在載入更多資料時，載入更多資料
                                if !isLoadingMoreData && diseases.count != historyLimitManager.currentHistoryCount {
                                    isLoadingMoreData = true // 顯示 ProgressView
                                    
                                    // 延遲一秒再載入更多資料，避免沒看到 ProgressView 就載入完畢
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        loadDiseaseHistory()
                                    }
                                }
                            }
                    }
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("確定要刪除嗎？"),
                    message: Text("這將永久刪除該分析紀錄"),
                    primaryButton: .destructive(Text("刪除")) {
                        if let diseaseToDelete = selectedDisease,
                           let indexToDelete = selectedDiseaseIndex {
                            modelContext.delete(diseaseToDelete) // 刪除選中的紀錄
                            do {
                                try modelContext.save() // 儲存變更
                                withAnimation {
                                    // 使用 `_` 忽略返回值避免警告
                                    _ = diseases.remove(at: indexToDelete) // 移除目前畫面上渲染出來的紀錄
                                }
                                historyLimitManager.decrementCount()
                                displayManager.needReloadMap = true
                            } catch {
                                deleteError = true
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
            // 此 alert 會導致無法顯示上方定義的刪除 alert，暫時先註解掉
            // .alert(isPresented: $deleteError) {
            //     Alert(
            //         title: Text("刪除失敗"),
            //         message: Text("請再試一次"),
            //         dismissButton: .default(Text("確定"))
            //     )
            // }
            .onAppear {
                // 進入頁面時或有新的分析紀錄時載入資料
                if diseases.isEmpty || displayManager.hasNewDiseaseData || displayManager.needReloadHistoryPage {
                    diseases.removeAll()
                    loadDiseaseHistory()
                }
            }
            .onAppear {
                if showTabBar {
                    withAnimation {
                        displayManager.isShowingTabBar = true
                    }
                } else {
                    withAnimation {
                        displayManager.isShowingTabBar = false
                    }
                }
            }
            // 從茶葉分析頁面中進入（已達儲存上限）並離開後，需要重新載入資料
            .onDisappear {
                if needReloadData {
                    displayManager.needReloadHistoryPage = true
                }
            }
            .navigationTitle("茶葉病害分析紀錄")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 確保在主執行緒執行
    @MainActor
    func loadDiseaseHistory() {
        // 使用 Task 避免進入此頁前 UI 卡住
        Task {
            do {
                var descriptor = FetchDescriptor<TeaDisease>(
                    // 從最新的資料開始載入
                    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
                )
                descriptor.fetchLimit = 10
                descriptor.fetchOffset = diseases.count
                descriptor.includePendingChanges = false
                
                let newBatch = try modelContext.fetch(descriptor)
                
                if !newBatch.isEmpty {
                    diseases.append(contentsOf: newBatch)
                }
                
                displayManager.hasNewDiseaseData = false
                displayManager.needReloadHistoryPage = false
                isLoadingMoreData = false
            } catch {
                print("載入資料失敗：\(error)")
                isLoadingMoreData = false
            }
        }
    }
    
    func historyLimitRow() -> some View {
        HStack(alignment: .bottom, spacing: 5) {
            Image(systemName: historyLimitManager.hasReachedLimit()
                  ? "tray.full"
                  : "tray")
            .font(.system(size: 17))
            .foregroundStyle(.secondary)
            
            // 格式：目前數量 / 上限，例如 1 / 20
            Text("\(historyLimitManager.currentHistoryCount) / \(historyLimitManager.historyLimit)")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: UIScreen.main.bounds.width - 40, alignment: .leading)
        .padding(.top, 10)
    }
}


#Preview {
    TeaDiseaseHistoryView()
        .environmentObject(HistoryLimitManager())
        .environmentObject(DisplayManager())
}
