import SwiftUI

struct TeaLeafInfoRow: View {
    var isImageError: Bool
    var isResultError: Bool
    var iconName: String
    var title: String
    var content: String?
    var containerWidth: CGFloat
    @Environment(\.colorScheme) var colorScheme // 取得目前顏色模式
    
    var body: some View {
        HStack {
            // 發生錯誤
            if isImageError || isResultError {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text(isImageError ? "圖片處理失敗" : "AI 預測發生錯誤，請再試一次")
                }
                .foregroundStyle(.red)
            } else {
                // 圖示跟標題
                HStack {
                    Image(systemName: iconName)
                    Text(title)
                }
                .foregroundStyle(colorScheme == .dark ?
                                 Color(red: 0.30, green: 0.60, blue: 0.40) :
                                 Color("ThemeColor")) // 深色模式使用更淡的綠色
                Spacer()
                // 內容
                if let content = content {
                    Text(content)
                } else {
                    LoadingPlaceholder()
                        .frame(width: 75, height: 25)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
        }
        .padding()
        .frame(maxWidth: containerWidth)
        .frame(height: 50)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
        .padding(.bottom, 15)
        .fontWeight(.bold)
    }
}

#Preview {
    TeaLeafAnalysisView(photoPickerItem: nil, cameraImage: UIImage(named: "test_brown"))
}
