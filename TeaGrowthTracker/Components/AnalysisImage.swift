import SwiftUI

struct AnalysisImage: View {
    let imageUrl: String
    let index: Int
    let width: CGFloat // 手機螢幕寬度
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { image in
            image
                .resizable()
                .scaledToFill()
                .scaleEffect(1.04) // 避免照片有白邊
                .frame(width: width, height: 350)
                .clipped()
                // 顯示右下角的頁數 Indicator
                .overlay(
                    indexIndicator(index: index)
                        .padding([.bottom, .leading], 10),
                    alignment: .bottomLeading
                )
        } placeholder: {
            ProgressView()
                // 載入時會與圖片大小一樣，不會導致載入時大小有不一致情形
                .frame(width: width, height: 350)
        }
    }
    
    private func indexIndicator(index: Int) -> some View {
        Text("\(index + 1) / 2")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .padding(8)
            .background(Color.black.opacity(0.7))
            .clipShape(Capsule())
    }
}

#Preview {
    AnalysisImage(
        imageUrl: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        index: 0,
        width: UIScreen.main.bounds.width
    )
}
