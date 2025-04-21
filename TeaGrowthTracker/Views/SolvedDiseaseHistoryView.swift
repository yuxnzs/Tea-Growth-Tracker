import SwiftUI
import SwiftData

struct SolvedDiseaseHistoryView: View {
    // 從 SwiftData 取得儲存的茶葉分析資料
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var historyLimitManager: HistoryLimitManager
    @EnvironmentObject var displayManager: DisplayManager
    
    @State private var diseases: [SolvedTeaDisease] = []
    @State private var isLoadingMoreData = false
    
    @State private var activeAlert: HistoryAlert?
    @State private var selectedDisease: SolvedTeaDisease? // 暫存選中要刪除的 disease
    @State private var selectedDiseaseIndex: Int?
    
    // 避免底部導航列遮擋內容
    let bottomPadding: CGFloat
    
    // 離線模式不需要傳入參數
    init(bottomPadding: CGFloat = 10) {
        self.bottomPadding = bottomPadding
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // 沒有資料
                if historyLimitManager.currentSolvedHistoryCount == 0 {
                    VStack {
                        Spacer().frame(height: 40)
                        Text("目前沒有已解決紀錄")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                }
                // 有資料但還在載入
                else if diseases.isEmpty {
                    historyLimitRow()
                    
                    ForEach(0..<5) { _ in
                        TeaDiseaseHistoryCardPlaceholder(isSolvedPage: .constant(true))
                            .padding(.bottom, 10)
                    }
                } else {
                    // 目前儲存的紀錄數量和上限
                    historyLimitRow()
                    
                    DiseaseCardList(
                        teaDiseases: diseases,
                        buttonSystemName: "bandage", // 將資料移到病害頁面按鈕
                        buttonAction: { disease, index in
                            if historyLimitManager.hasReachedLimit() {
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
                                let pageSize = 10
                                let totalCount = historyLimitManager.currentSolvedHistoryCount
                                let currentCount = diseases.count
                                
                                // 確定還有更多資料
                                let hasMore = currentCount < totalCount
                                // 確定目前的資料數量是完整的一頁
                                let isFullPage = currentCount > 0 && currentCount % pageSize == 0
                                if !isLoadingMoreData && hasMore && isFullPage {
                                    isLoadingMoreData = true // 顯示 ProgressView
                                    
                                    // 延遲一秒再載入更多資料，避免沒看到 ProgressView 就載入完畢
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        loadSolvedHistory(skipDelay: true)
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
                                performDeleteSolved(disease: disease, index: index)
                            }
                        },
                        secondaryButton: .cancel(Text("取消"))
                    )
                case .solved:
                    return Alert(
                        title: Text("確定要移回病害頁面嗎？"),
                        message: Text("這會將此筆紀錄移回病害頁面"),
                        primaryButton: .default(Text("移回病害頁面")) {
                            if let disease = selectedDisease,
                               let index = selectedDiseaseIndex {
                                markAsUnsolved(disease: disease, index: index)
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
                    return Alert(title: Text("病害紀錄已達儲存上限"),
                                 message: Text("請刪除一些紀錄再試一次"),
                                 dismissButton: .default(Text("確定")))
                }
            }
            .onAppear {
                // 進入頁面時，載入資料（每次離開時頁面被銷毀，因此不用 if 判斷是否需要重載）
                loadSolvedHistory()
            }
            .navigationTitle("已解決病害紀錄")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 確保在主執行緒執行
    @MainActor
    func loadSolvedHistory(skipDelay: Bool = false) {
        let startTime = Date()
        
        // 使用 Task 避免進入此頁前 UI 卡住
        Task {
            do {
                var descriptor = FetchDescriptor<SolvedTeaDisease>(
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
                
                isLoadingMoreData = false
            } catch {
                print("載入資料失敗：\(error)")
                isLoadingMoreData = false
            }
        }
    }
    
    @MainActor
    func performDeleteSolved(disease: SolvedTeaDisease, index: Int) {
        modelContext.delete(disease)
        do {
            try modelContext.save()
            withAnimation { _ = diseases.remove(at: index) }
            historyLimitManager.decrementSolvedCount()
        } catch {
            activeAlert = .deleteError
        }
    }
    
    // 將選中的紀錄移回 TeaDisease
    @MainActor
    func markAsUnsolved(disease: SolvedTeaDisease, index: Int) {
        let back = TeaDisease(
            teaImage: disease.teaImage,
            diseaseName: disease.diseaseName,
            confidenceLevel: disease.confidenceLevel,
            longitude: disease.longitude,
            latitude: disease.latitude
        )
        modelContext.insert(back) // 移回病害頁面
        modelContext.delete(disease) // 刪除現有的病害紀錄
        
        do {
            try modelContext.save()
            withAnimation { _ = diseases.remove(at: index) }
            historyLimitManager.decrementSolvedCount()
            historyLimitManager.incrementCount()
            displayManager.needReloadHistoryPage = true
        } catch {
            activeAlert = .moveError
        }
    }
    
    func historyLimitRow() -> some View {
        HStack(alignment: .bottom, spacing: 5) {
            Image(systemName: historyLimitManager.hasReachedSolvedLimit()
                  ? "tray.full"
                  : "tray")
            .font(.system(size: 17))
            .foregroundStyle(.secondary)
            
            // 格式：目前數量 / 上限，例如 1 / 20
            Text("\(historyLimitManager.currentSolvedHistoryCount) / \(historyLimitManager.historyLimit)")
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
