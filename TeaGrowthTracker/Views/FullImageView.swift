import SwiftUI

struct FullImageView: View {
    @Binding var selectedTab: Int? // 預設顯示選項
    let images: [String]
    
    var body: some View {
        if selectedTab != nil {
            // 根據 selectedTab 的值顯示對應的圖片
            TabView(selection: $selectedTab) {
                ForEach(images.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: images[index])) { image in
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
        } else {
            // 沒傳入 selectedTab 時，以預設方式顯示
            TabView {
                ForEach(images.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: images[index])) { image in
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
    }
}

#Preview {
    FullImageView(
        selectedTab: .constant(nil),
        images: [
            "https://plus.unsplash.com/premium_photo-1692049124070-87d5ddfea09a?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        ])
}
