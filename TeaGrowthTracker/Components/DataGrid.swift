import SwiftUI

struct DataGrid: View {
    let teaData: TeaData
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 6) {
                DataCard(title: "日期", date: teaData.date)
                
                Spacer()
                
                let (weatherIcon, weatherColor) = getWeatherIconAndColor(weather: teaData.weather)
                DataCard(title: "天氣",
                         weatherIcon: weatherIcon,
                         weatherColor: weatherColor)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 6) {
                DataCard(title: "生長率參考值", growth: teaData.growth)
                
                Spacer()
                
                DataCard(title: "種植程度", plantingRate: teaData.plantingRate)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height / 2.35)
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
    DataGrid(
        teaData: TeaData(
            area: "A",
            originalImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            analyzedImage: "https://images.unsplash.com/photo-1605105777592-c3430a67d033?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            date: "2024-06-01",
            weather: "雨",
            growth: "90%",
            plantingRate: "高"
        )
    )
}

