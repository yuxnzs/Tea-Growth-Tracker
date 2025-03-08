import SwiftUI

struct DataGrid: View {
    let titles: [String]
    let values: [String]
    let isTeaData: Bool
    
    init(titles: [String], values: [String], isTeaData: Bool = false) {
        self.titles = titles
        self.values = values
        self.isTeaData = isTeaData
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 6) {
                DataCard(title: titles[0], data: values[0], needSmallerSize: isTeaData)
                
                Spacer()
                
                if isTeaData {
                    let (weatherIcon, weatherColor) = getWeatherIconAndColor(weather: values[1])
                    DataCard(
                        title: titles[1],
                        weatherIcon: weatherIcon,
                        weatherColor: weatherColor
                    )
                } else {
                    DataCard(title: titles[1], data: values[1])
                }
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 6) {
                DataCard(title: titles[2], data: values[2])
                
                Spacer()
                
                DataCard(title: titles[3], data: values[3])
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
        titles: ["日期", "天氣", "生長率參考值", "種植程度"],
        values: ["2024-06-01", "雨", "90%", "高"],
        isTeaData: true
    )
}

