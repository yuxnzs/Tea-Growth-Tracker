import SwiftUI

struct DataGrid: View {
    @EnvironmentObject var teaModel: TeaModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                DataCard(title: "日期", date: teaModel.date)
                
                let (weatherIcon, weatherColor) = getWeatherIconAndColor(weather: teaModel.weather)
                DataCard(title: "天氣",
                        weatherIcon: weatherIcon,
                        weatherColor: weatherColor)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 20) {
                DataCard(title: "生長情形", growth: teaModel.growth)
                
                DataCard(title: "水流方向", waterFlow: teaModel.waterFlow)
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
    DataGrid()
        .environmentObject(TeaModel(
            teaGardenID: 1,
            name: "龍井茶園",
            location: "新北市石碇區",
            originalImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            analyzedImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            date: "2024-06-01",
            weather: "雨",
            growth: "90 %",
            waterFlow: "下"
        ))
}

