import SwiftUI

struct CustomTipView: View {
    let title: String
    let message: String
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "lightbulb")
                .resizable()
                .scaledToFit()
                .foregroundColor(.blue)
                .font(.system(size: 24))
                .frame(width: 45,height: 45)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                    .padding(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

#Preview {
    CustomTipView(title: "教學提示", message: "你可以點擊左側的 ✅ 圖示來標記紀錄為已解決，或是右側按鈕刪除紀錄。") {
        
    }
}
