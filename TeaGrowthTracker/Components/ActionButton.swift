import SwiftUI

struct ActionButton: View {
    let title: String
    let buttonWidth: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    var body: some View {
        Text(title)
            .font(.headline)
            .bold()
            .padding()
            .frame(width: buttonWidth, height: 50)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(foregroundColor)
    }
}

#Preview {
    ActionButton(
        title: "儲存此次分析",
        buttonWidth: 300,
        backgroundColor: Color(red: 0.098, green: 0.412, blue: 0.235),
        foregroundColor: .white
    )
}
