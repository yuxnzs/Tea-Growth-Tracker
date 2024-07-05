import SwiftUI

struct AnalysisView: View {
    @State private var selectedIndex: Int = 0 // 追蹤目前圖片選中的 index
    
    let teaData: TeaData
    var isSheet: Bool
    
    init(teaData: TeaData, isSheet: Bool = false) {
        self.teaData = teaData
        self.isSheet = isSheet
    }
    
    var body: some View {
        NavigationStack {
            // 讓小螢幕裝置如 iPhone SE 也能看到完整頁面，所以整個畫面使用 ScrollView
            ScrollView {
                GeometryReader { geometry in
                    // 用 overlay 會有點不到的問題，所以用 ZStack 做右下角跳頁按鈕
                    ZStack(alignment: .bottom) {
                        // 圖片區
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(0..<2) { index in
                                    VStack {
                                        if index == 0 {
                                            AnalysisImage(imageUrl: teaData.originalImage, index: index, width: geometry.size.width)
                                        } else if index == 1 {
                                            AnalysisImage(imageUrl: teaData.analyzedImage, index: index, width: geometry.size.width)
                                        }
                                    }
                                    // 手機螢幕的寬度
                                    // UIScreen：裝置螢幕、main：主要螢幕、bounds：螢幕邊界（寬跟高）、width：邊界寬度
                                    // .frame(width: UIScreen.main.bounds.width)
                                }
                            }
                        }
                        // 讓 ScrollView 滑動時有一格一格效果
                        .content.offset(x: -CGFloat(selectedIndex) * geometry.size.width)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let threshold: CGFloat = 50
                                    if value.translation.width < -threshold {
                                        selectedIndex = min(selectedIndex + 1, 1) // 1 是最大 index
                                    } else if value.translation.width > threshold {
                                        selectedIndex = max(selectedIndex - 1, 0) // 0 是最小 index
                                    }
                                }
                        )
                        .animation(.easeInOut, value: selectedIndex)
                        
                        // 跳頁到 FullImageView 按鈕
                        VStack {
                            NavigationLink {
                                FullImageView(
                                    selectedTab: $selectedIndex,
                                    isAnalysisView: true,
                                    images: [teaData.originalImage, teaData.analyzedImage])
                            } label: {
                                Image(systemName: "arrow.down.left.and.arrow.up.right")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .padding(.bottom, 10)
                            .padding(.trailing, 60)
                        }
                    }
                }
                // ignoresSafeArea 後元素實際還是在原本位置
                // 所以不能單純透過調整高度讓下方移上來
                // 這樣會造成其他頁面跳過來時位置錯誤，與預覽不同
                // .frame(height: 290)
                
                Spacer().frame(height: 355)
                
                // 從 Sheet 過來位置會長得不一樣，所以需特別處理
                VStack(alignment: .leading) {
                    Text("\(teaData.area) 區分析結果")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .padding(.leading, 20)
                    
                    DataGrid(teaData: teaData)
                }
                .padding(.bottom, isSheet ? -20 : UIScreen.main.bounds.height / 20)
            }
            .ignoresSafeArea()
        }
        
    }
}

#Preview {
    AnalysisView(
        teaData: TeaData(
            area: "A",
            originalImage: "https://plus.unsplash.com/premium_photo-1692049124070-87d5ddfea09a?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            analyzedImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            date: "2024-06-01",
            weather: "雨",
            growth: "90%",
            plantingRate: "下"
        ))
}
