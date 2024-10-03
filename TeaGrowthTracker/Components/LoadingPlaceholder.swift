import SwiftUI

struct LoadingPlaceholder: View {
    @State private var isAnimating = true
    
    var body: some View {
        Color.gray
            .opacity(isAnimating ? 0.15 : 0.35)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                    isAnimating.toggle()
                }
            }
    }
}

#Preview {
    LoadingPlaceholder()
}
