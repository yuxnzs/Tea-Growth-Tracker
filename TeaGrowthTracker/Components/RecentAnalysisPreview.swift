import SwiftUI

struct RecentAnalysisPreview: View {
    @State var isLoading = true
    let teaData: TeaData
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 茶園圖片
            VStack {
                AsyncImage(url: URL(string: teaData.originalImage)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(1.1) // 避免照片有白邊
                } placeholder: {
                    LoadingPlaceholder()
                        .onDisappear() {
                            isLoading = false
                        }
                }
            }
            // 給 VStack 預設高度，在圖片還在載入時不會因為整個 VStack 沒有高度
            // 導致下方日期 VStack 在中間，沒被撐到最下面，跟 ProgressView 疊在一起
            
            // 這裡原本設定 maxWidth: .infinity，但設定後發現跟 maxWidth: 210 會有所不同，不知道為什麼
            // 照理來說父視圖設定 width: 210 後，子視圖設定 maxWidth: .infinity 應該也是 210
            // 但結果 maxWidth: .infinity 與 maxWidth: 210 不同，會影響下方 VStack 的寬度與圖片寬度一樣，而不是跟父視圖一樣
            // 目前推測是因為圖片過寬導致意想不到的佈局效果
            .frame(width: 210, height: 150)
            
            // 日期
            VStack {
                HStack {
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                    
                    Text(teaData.date)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .padding(.leading, 15)
            .frame(width: 210, alignment: .leading)
            .frame(height: 50)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: isLoading ? 0 : 20) // 圖片載入中時日期容器不要有陰影
        }
        .frame(width: 210, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview() {
    RecentAnalysisPreview(
        teaData: TeaData(
            area: "A",
            originalImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            analyzedImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            date: "2024-06-01",
            weather: "雨",
            growth: "90%",
            plantingRate: "高"
        ))
}
