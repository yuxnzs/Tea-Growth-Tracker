import SwiftUI

struct TeaDetail: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                TeaInfo(title: "日期", date: "2024/06/01")
                        
                
                TeaInfo(title: "天氣",
                        weather: "cloud.sun.fill",
                        weatherColor: .yellow)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 20) {
                TeaInfo(title: "生長情形", growth: "90 %")
                
                TeaInfo(title: "水流方向", growth: "下")
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TeaDetail()
}
