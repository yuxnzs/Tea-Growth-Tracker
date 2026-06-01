import SwiftUI

struct CircularProgressView: View {
    let percentage: Double
    @State private var animatedPercentage: Double = 0
    
    var body: some View {
        ZStack {
            // 背景圓圈
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 14)
            
            // 前景進度圓圈
            Circle()
                .trim(from: 0.0, to: animatedPercentage)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.green]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: animatedPercentage)
            
            // 百分比與標題文字
            VStack {
                if animatedPercentage == 0 { }
                else {
                    Text("\(String(format: "%.1f", animatedPercentage * 100))%")
                        .font(.title2.bold())
                }
                
                Text("信心程度")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
            .opacity(animatedPercentage > 0 ? 1 : 0) // 根據 percentage 控制透明度
            .animation(.easeInOut(duration: 0.8), value: animatedPercentage) // 動畫過渡
        }
        .frame(width: 120, height: 120)
        .onAppear {
            animatedPercentage = 0 // 初始化為 0
            withAnimation(.easeOut(duration: 1.0)) {
                animatedPercentage = percentage / 100 // 計算百分比
            }
        }
    }
}

#Preview {
    CircularProgressView(percentage: 0.5)
        .padding()
    
}
