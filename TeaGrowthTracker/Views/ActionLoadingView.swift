import SwiftUI

struct ActionLoadingView: View {
    let useWhiteProgressView: Bool
    
    init(useWhiteProgressView: Bool = false) {
        self.useWhiteProgressView = useWhiteProgressView
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2) // 與系統的 alert 出現時背景透明度相似
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            ProgressView()
                .tint(useWhiteProgressView ? .white : .gray)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ActionLoadingView()
}
