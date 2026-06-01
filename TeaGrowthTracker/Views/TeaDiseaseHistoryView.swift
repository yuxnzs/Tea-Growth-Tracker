import SwiftUI
import SwiftData
import TipKit

// 定義 Alert 類型
enum HistoryAlert: Identifiable {
    case delete, solved, deleteError, moveError, reachLimit
    var id: Self { self } // 實作 Identifiable protocol
}

struct TeaDiseaseHistoryView: View {
    // 從 SwiftData 取得儲存的茶葉分析資料
    @Environment(\.modelContext) private var modelContext
    // 取得目前顏色模式
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var historyLimitManager: HistoryLimitManager
    @EnvironmentObject var displayManager: DisplayManager
    
    @State private var diseases: [TeaDisease] = []
    @State private var isLoadingMoreData = false
    
    @State private var activeAlert: HistoryAlert?
    @State private var selectedDisease: TeaDisease? // 暫存選中要刪除的 disease
    @State private var selectedDiseaseIndex: Int?
    
    @State private var pushToSolvedPage = false
    
    @State private var teachingTip = TeachingTip()
    @State private var showTeachingTip = false
    @State private var tipId = UUID()
    
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
                    
                    if showTeachingTip {
                        CustomTipView(title: "教學提示", message: "你可以點擊左側的 ✅ 圖示來標記紀錄為已解決，或是右側按鈕刪除紀錄。") {
                            withAnimation {
                                showTeachingTip = false
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 10)
                        .animation(.easeInOut, value: showTeachingTip)
                    }
                    
                    DiseaseCardList(
                        teaDiseases: diseases,
                        buttonSystemName: "checkmark", // 已解決按鈕
                        buttonAction: { disease, index in
                            if historyLimitManager.hasReachedSolvedLimit() {
                                activeAlert = .reachLimit
                                return
                            }
                            selectedDisease = disease
                            selectedDiseaseIndex = index
                            activeAlert = .solved
                        },
                        deleteAction: { disease, index in
                            selectedDisease = disease
                            selectedDiseaseIndex = index
                            activeAlert = .delete
                        }
                    )
                    .padding(.bottom, bottomPadding)
                    
                    if isLoadingMoreData {
                        ProgressView()
                            .padding(.top, 20)
                    }
                    
                    // 使用 LazyVStack + Color.clear 來偵測是否滑到最底部
                    LazyVStack {
                        Color.clear
                            .onAppear {
                                //                                let pageSize = 10
                                let totalCount = historyLimitManager.currentHistoryCount
                                let currentCount = diseases.count
                                
                                // 確定還有更多資料
                                let hasMore = currentCount < totalCount
                                // 確定目前的資料數量是完整的一頁
                                // && currentCount % pageSize == 0
                                let isFullPage = currentCount > 0
                                if !isLoadingMoreData && hasMore && isFullPage {
                                    isLoadingMoreData = true // 顯示 ProgressView
                                    
                                    // 延遲一秒再載入更多資料，避免沒看到 ProgressView 就載入完畢
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        loadDiseaseHistory(skipDelay: true)
                                    }
                                }
                            }
                    }
                }
            }
            .alert(item: $activeAlert) { kind in
                switch kind {
                case .delete:
                    return Alert(
                        title: Text("確定要刪除嗎？"),
                        message: Text("這將永久刪除該分析紀錄"),
                        primaryButton: .destructive(Text("刪除")) {
                            if let disease = selectedDisease,
                               let index = selectedDiseaseIndex {
                                performDelete(disease: disease, index: index)
                            }
                        },
                        secondaryButton: .cancel(Text("取消"))
                    )
                case .solved:
                    return Alert(
                        title: Text("確定要將此紀錄標記為已解決嗎？"),
                        message: Text("這會將此筆紀錄移至已解決頁面"),
                        primaryButton: .default(Text("移至已解決")) {
                            if let disease = selectedDisease,
                               let index = selectedDiseaseIndex {
                                markAsSolved(disease: disease, index: index)
                            }
                        },
                        secondaryButton: .cancel(Text("取消"))
                    )
                case .deleteError:
                    return Alert(title: Text("刪除失敗"),
                                 message: Text("請再試一次"),
                                 dismissButton: .default(Text("確定")))
                case .moveError:
                    return Alert(title: Text("搬移失敗"),
                                 message: Text("請再試一次"),
                                 dismissButton: .default(Text("確定")))
                    
                case .reachLimit:
                    return Alert(title: Text("已解決紀錄已達儲存上限"),
                                 message: Text("請刪除一些紀錄再試一次"),
                                 dismissButton: .default(Text("確定")))
                }
            }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // 顯示教學提示
                        withAnimation {
                            showTeachingTip.toggle()
                        }
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        pushToSolvedPage = true
                    } label: {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            .navigationDestination(isPresented: $pushToSolvedPage) {
                SolvedDiseaseHistoryView(bottomPadding: bottomPadding)
                    .environmentObject(historyLimitManager)
                    .environmentObject(displayManager)
            }
        }
    }
    
    // 確保在主執行緒執行
    @MainActor
    func loadDiseaseHistory(skipDelay: Bool = false) {
        let startTime = Date()
        
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
                
                let endTime = Date()
                let timeInterval = endTime.timeIntervalSince(startTime)
                
                // 如果取得資料時間小於 1.5 秒，繼續等待直到滿 1.5 秒，避免畫面快速閃爍
                if !skipDelay && timeInterval < 1.5 {
                    let remainingTime = 1.5 - timeInterval
                    try await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000)) // 等待剩餘的時間
                }
                
                if !newBatch.isEmpty {
                    withAnimation {
                        diseases.append(contentsOf: newBatch)
                    }
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
    
    @MainActor
    func performDelete(disease: TeaDisease, index: Int) {
        modelContext.delete(disease)
        do {
            try modelContext.save()
            withAnimation { _ = diseases.remove(at: index) }
            historyLimitManager.decrementCount()
            displayManager.needReloadMap = true
        } catch {
            activeAlert = .deleteError
        }
    }
    
    @MainActor
    func markAsSolved(disease: TeaDisease, index: Int) {
        // 將選中的病害資料移至 SolvedTeaDisease
        let solvedDisease = SolvedTeaDisease(teaDisease: disease)
        modelContext.insert(solvedDisease) // 插入至已解決
        modelContext.delete(disease) // 刪除現有的病害紀錄
        
        do {
            try modelContext.save()
            withAnimation { _ = diseases.remove(at: index) }
            historyLimitManager.decrementCount()
            historyLimitManager.incrementSolvedCount()
            displayManager.needReloadMap = true
        } catch {
            activeAlert = .moveError
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
