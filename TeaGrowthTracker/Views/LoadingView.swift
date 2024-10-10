import SwiftUI

struct LoadingView: View {
    @State private var offsetY: CGFloat = 0
    @State private var showProgressView: Bool = false
    
    var body: some View {
        VStack {
            Image("leaf")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .offset(y: offsetY) // 透過 y 來上移圖片
                .onAppear {
                    // 進入 App 0.5 秒後上移
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            offsetY = -22 // 圖片上移
                        }
                        
                        // 延遲 0.1 秒讓 ProgressView 同步淡入
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeIn(duration: 0.5)) {
                                showProgressView = true
                            }
                        }
                    }
                }
            
            if showProgressView {
                ProgressView()
                    .transition(.opacity)
                    .tint(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("ThemeColor"))
        .ignoresSafeArea()
    }
}

#Preview {
    LoadingView()
}
