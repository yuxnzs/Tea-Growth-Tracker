import SwiftUI
import SDWebImageSwiftUI

struct FullImageView: View {
    @Binding var selectedTab: Int // 預設顯示選項
    let isAnalysisView: Bool
    let asyncImages: [String]?
    let useUIImage: Bool // UserTeaImage 使用 UIImage
    let uiImage: UIImage?
    
    var body: some View {
        if isAnalysisView {
            // AnalysisView 使用 selectedTab 來追蹤目前圖片選中的 index
            if let asyncImages = asyncImages {
                TabView(selection: $selectedTab) {
                    ForEach(asyncImages.indices, id: \.self) { index in
                        WebImage(url: URL(string: asyncImages[index])) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                                .tint(.white)
                        }
                        .tag(index) // 設置標籤選項
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .background(.black)
            }
        } else {
            // 不用 selectedTab 時，以預設方式顯示
            TabView {
                if useUIImage, let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .tag(0)
                } else if let asyncImages = asyncImages {
                    ForEach(asyncImages.indices, id: \.self) { index in
                        WebImage(url: URL(string: asyncImages[index])) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            `ProgressView`()
                                .tint(.white)
                        }
                        .tag(index) // 設置標籤選項
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .background(.black)
        }
    }
}

#Preview {
    FullImageView(
        selectedTab: .constant(0),
        isAnalysisView: true,
        asyncImages: [
            "https://plus.unsplash.com/premium_photo-1692049124070-87d5ddfea09a?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        ],
        useUIImage: false,
        uiImage: nil
    )
}
