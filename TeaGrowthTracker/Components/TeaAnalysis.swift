import SwiftUI

struct TeaAnalysis: View {
    @EnvironmentObject var teaData: TeaData
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                TeaInfo(title: "日期", date: teaData.date)
                
                let (weatherIcon, weatherColor) = getWeatherIconAndColor(weather: teaData.weather)
                TeaInfo(title: "天氣",
                        weatherIcon: weatherIcon,
                        weatherColor: weatherColor)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 20) {
                TeaInfo(title: "生長情形", growth: "90 %")
                
                TeaInfo(title: "水流方向", waterFlow: "下")
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // 透過後端傳來的天氣描述，轉換成相對應的 Icon 跟 Color
    private func getWeatherIconAndColor(weather: String) -> (String, Color) {
        switch weather {
        case "晴":
            return ("sun.max.fill", .yellow)
        case "陰":
            return ("cloud.fill", .gray)
        case "雨":
            return ("cloud.rain.fill", .blue)
        default:
            return ("questionmark.circle.fill", .gray)
        }
    }
}

#Preview {
    TeaAnalysis()
        .environmentObject(TeaData(
            teaGardenID: 1,
            name: "龍井茶園",
            location: "新北市石碇區",
            originalImage: "tea-test",
            analyzedImage: "tea-test",
            date: "2024-06-01",
            weather: "雨",
            growth: "90 %",
            waterFlow: "下"
        ))
}

