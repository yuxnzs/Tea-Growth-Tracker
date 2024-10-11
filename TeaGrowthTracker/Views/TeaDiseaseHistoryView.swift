import SwiftUI
import SwiftData

struct TeaDiseaseHistoryView: View {
    // 從 SwiftData 取得儲存的茶葉分析資料
    @Environment(\.modelContext) private var modelContext
    @Query var diseases: [TeaDisease]
    
    @EnvironmentObject var historyLimitManager: HistoryLimitManager
    
    @State private var showDeleteAlert = false
    @State private var deleteError = false
    @State private var selectedDisease: TeaDisease? // 暫存選中要刪除的 disease
    @State private var showActionLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if diseases.isEmpty {
                    VStack {
                        Spacer().frame(height: 40)
                        Text("目前沒有分析紀錄")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                } else {
                    // 目前儲存的紀錄數量和上限
                    HStack(alignment: .bottom, spacing: 5) {
                        Image(systemName: historyLimitManager.hasReachedLimit(diseaseCount: diseases.count)
                              ? "tray.full"
                              : "tray")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                        
                        // 目前數量 / 上限，例如 1 / 5
                        Text("\(diseases.count) / \(historyLimitManager.historyLimit)")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width - 40, alignment: .leading)
                    .padding(.top, 10)
                    
                    VStack {
                        // 確保只渲染最近五筆分析紀錄（儲存時已檢查最多 5 筆，這裡再確認一次）
                        ForEach(diseases.reversed().prefix(5), id: \.id) { disease in
                            TeaDiseaseHistoryCard(
                                teaImage: disease.teaImage,
                                diseaseName: disease.diseaseName,
                                confidenceLevel: disease.confidenceLevel,
                                analysisDate: disease.analysisDate,
                                onDelete: {
                                    showActionLoading = true
                                    
                                    DispatchQueue.main.async {
                                        selectedDisease = disease
                                        showDeleteAlert = true
                                        showActionLoading = false
                                    }
                                }
                            )
                            .padding(.bottom, 10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("確定要刪除嗎？"),
                    message: Text("這將永久刪除該分析紀錄"),
                    primaryButton: .destructive(Text("刪除")) {
                        withAnimation {
                            if let diseaseToDelete = selectedDisease {
                                modelContext.delete(diseaseToDelete) // 刪除選中的紀錄
                                do {
                                    try modelContext.save() // 儲存變更
                                } catch {
                                    deleteError = true
                                }
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
            .overlay {
                if showActionLoading {
                    ActionLoadingView()
                }
            }
            .navigationTitle("茶葉病害分析紀錄")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    TeaDiseaseHistoryView()
        .environmentObject(HistoryLimitManager())
}
