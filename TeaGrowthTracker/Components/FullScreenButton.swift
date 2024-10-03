import SwiftUI

struct FullScreenButton<Destination: View>: View {
    let destination: Destination
    // AnalysisView 由於圖片為兩張，padding 與只有一張的 UserTeaImage 不同
    let isAnalysisView: Bool
    
    var body: some View {
        VStack {
            NavigationLink {
                destination
            } label: {
                Image(systemName: "arrow.down.left.and.arrow.up.right")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.black.opacity(0.7))
                    .clipShape(Circle())
            }
            .padding(.bottom, 10)
            .padding(.trailing, isAnalysisView ? 60 : 10)
        }
    }
}

#Preview {
    FullScreenButton(
        destination: Text("Fullscreen"),
        isAnalysisView: false
    )
}
