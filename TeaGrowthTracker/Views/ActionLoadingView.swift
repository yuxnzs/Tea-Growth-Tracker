import SwiftUI

struct ActionLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            ProgressView()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ActionLoadingView()
}
