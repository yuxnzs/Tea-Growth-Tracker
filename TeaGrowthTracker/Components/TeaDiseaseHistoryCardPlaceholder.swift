import SwiftUI

struct TeaDiseaseHistoryCardPlaceholder: View {
    var body: some View {
        VStack {
            // 使用縮小後的圖片進行顯示，避免圖片過大造成卡頓
            LoadingPlaceholder()
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 200)
        // 左上角日期
        .overlay(alignment: .topLeading) {
            LoadingPlaceholder()
                .frame(width: 90, height: 30)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.leading, 8)
                .padding(.top, 8)
        }
        // 右上角刪除按鈕
        .overlay(alignment: .topTrailing) {
            Button(action: {}) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .padding(7)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .padding(.trailing, 8)
            .padding(.top, 8)
        }
        // 底部資訊
        .overlay(alignment: .bottomLeading) {
            VStack {
                HStack(alignment: .center, spacing: 0) {
                }
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 45)
            .background(.ultraThinMaterial)
            .shadow(color: .gray.opacity(0.5), radius: 20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 20)
        .buttonStyle(.plain)
    }
}

#Preview {
    TeaDiseaseHistoryCardPlaceholder()
}
