import SwiftUI

struct AreaListView: View {
    @EnvironmentObject var teaService: TeaService
    
    var groupedTeaData: [String: [TeaData]] {
        Dictionary(grouping: teaService.teaGardenData.flatMap { $0.teaData }, by: { $0.date })
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedTeaData.keys.sorted(), id: \.self) { date in
                    Section(header: Text(date)) {
                        ForEach(groupedTeaData[date] ?? []) { teaData in
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
