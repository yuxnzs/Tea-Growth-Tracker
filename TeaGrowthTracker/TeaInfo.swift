import SwiftUI

struct TeaInfo: View {
    let title: String
    let date: String?
    let weather: String?
    let weatherColor: Color?
    let growth: String?
    let waterFlow: String?
    
    init(title: String, date: String? = nil, weather: String? = nil, weatherColor: Color? = nil, growth: String? = nil, waterFlow: String? = nil) {
        self.title = title
        self.date = date
        self.weather = weather
        self.weatherColor = weatherColor
        self.growth = growth
        self.waterFlow = waterFlow
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.top, 10)
            .padding(.horizontal, 12)
            
            VStack {
                if let date = date {
                    Text(date)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                if let weather = weather, let weatherColor = weatherColor {
                    Image(systemName: weather)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(weatherColor)
                }
                
                if let growth = growth {
                    Text(growth)
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                if let waterFlow = waterFlow {
                    Text(waterFlow)
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 170, height: 170)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    TeaInfo(title: "生長情形",
//            date: "2021-09-01",
            weather: "cloud.sun",
            weatherColor: .yellow
//            growth: "95 %",
//            waterFlow: "上流"
    )
    .padding()
}
