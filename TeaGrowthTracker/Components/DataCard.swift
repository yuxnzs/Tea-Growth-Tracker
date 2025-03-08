import SwiftUI

struct DataCard: View {
    let title: String
    let data: String?
    let weatherIcon: String?
    let weatherColor: Color?
    let needSmallerSize: Bool
    
    init(title: String, data: String? = nil, weatherIcon: String? = nil, weatherColor: Color? = nil, needSmallerSize: Bool = false) {
        self.title = title
        self.data = data
        self.weatherIcon = weatherIcon
        self.weatherColor = weatherColor
        self.needSmallerSize = needSmallerSize
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 欄位名稱
            VStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.top, 13)
            .padding(.horizontal, 13)
            
            // 資料
            VStack {
                if let weatherIcon = weatherIcon, let weatherColor = weatherColor {
                    Image(systemName: weatherIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(weatherColor)
                }
                
                if let data = data {
                    Text(data)
                        .font(needSmallerSize ? .title2 : .title)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
}

#Preview() {
    DataCard(title: "生長率參考值", data: "95 %")
        .padding()
}
