import SwiftUI

struct AreaListView: View {
    @EnvironmentObject var teaService: TeaService
    
    var groupedTeaData: [String: [(TeaData, AiPlantingImages?)]] {
        Dictionary(grouping: teaService.teaGardenData.flatMap { teaGarden in
            teaGarden.teaData.map { teaData in
                (teaData, teaGarden.aiPlantingImages)
            }
        }, by: { $0.0.date })
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedTeaData.keys.sorted(), id: \.self) { date in
                    Section(header: Text(date)) {
                        // 檢查是否有 aiPlantingImages
                        // 並只在第一次出現時顯示，不會重複交錯顯示
                        let aiImagesExist = groupedTeaData[date]?.contains(where: { $0.1 != nil }) == true
                        if aiImagesExist {
                            if let images = groupedTeaData[date]?.first(where: { $0.1 != nil })?.1 {
                                NavigationLink {
                                    FullImageView(
                                        selectedTab: .constant(0),
                                        isAnalysisView: false,
                                        asyncImages: [
                                            images.original,
                                            images.marked
                                        ],
                                        useUIImage: false,
                                        uiImage: nil
                                    )
                                } label: {
                                    Text("AI 標記種植程度低區域")
                                }
                            } else {
                                /* 即使沒有 aiPlantingImages 就不會顯示
                                   但避免出錯，因此加上 else 提示沒有圖片 */
                                Text("無標記圖片")
                            }
                        }
                        ForEach(groupedTeaData[date] ?? [], id: \.0.id) { (teaData, aiImages) in
                            NavigationLink {
                                AnalysisView(teaData: teaData)
                            } label: {
                                Text("\(teaData.area) 區")
                            }
                        }
                    }
                }
            }
            .navigationTitle("選擇區域")
        }
    }
}

#Preview {
    AreaListView()
        .environmentObject(TeaService(
            teaGardenData: [
                Tea(
                    teaGardenID: 1,
                    name: "龍井茶園",
                    location: "新北市石碇區",
                    aiPlantingImages: AiPlantingImages(
                        original: "https://teaimages.blob.core.windows.net/tea-images/1_0505_A_ori.png",
                        marked: "https://teaimages.blob.core.windows.net/tea-images/1_0505_A_ori.png"
                    ),
                    teaData: [
                        TeaData(
                            area: "A",
                            originalImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            analyzedImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            date: "2024-06-01",
                            weather: "雨",
                            growth: "90%",
                            plantingRate: "高"
                        ),
                        TeaData(
                            area: "B",
                            originalImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            analyzedImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            date: "2024-06-01",
                            weather: "雨",
                            growth: "90%",
                            plantingRate: "中"
                        ),
                        TeaData(
                            area: "C",
                            originalImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            analyzedImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            date: "2024-06-01",
                            weather: "晴",
                            growth: "90%",
                            plantingRate: "低"
                        )
                    ]
                ),
                Tea(
                    teaGardenID: 1,
                    name: "龍井茶園",
                    location: "新北市石碇區",
                    teaData: [
                        TeaData(
                            area: "A",
                            originalImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            analyzedImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            date: "2024-06-10",
                            weather: "雨",
                            growth: "90%",
                            plantingRate: "高"
                        ),
                        TeaData(
                            area: "B",
                            originalImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            analyzedImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            date: "2024-06-10",
                            weather: "雨",
                            growth: "90%",
                            plantingRate: "高"
                        ),
                        TeaData(
                            area: "C",
                            originalImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            analyzedImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            date: "2024-06-10",
                            weather: "晴",
                            growth: "90%",
                            plantingRate: "中"
                        )
                    ]
                )
            ]
        ))
}
