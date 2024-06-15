import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 30) {
                // 頂部資訊欄
                
                
                HStack {
                    // 文字資訊
                    VStack(spacing: 20) {
                        // 茶園名稱
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding(.trailing, 3)
                            
                            Text("阿文茶園")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        // 茶園位置
                        HStack {
                            Image(systemName: "location")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding(.trailing, 3)
                            
                            Text("新北市石碇區")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                    
                    // 茶圖標
                    VStack {
                        Image("leaf")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                    }
                }
                .frame(maxWidth: .infinity)
                // 自動計算 Safe Area 的高度
                .padding(.top, geometry.safeAreaInsets.top + 20)
                .padding(.bottom)
                .padding(.horizontal)
                .background(Color(red: 0.098, green: 0.412, blue: 0.235)) // #19693c
                .clipShape(RoundedRectangle(cornerRadius: 25))
                
                
                // 最近一次分析結果
                VStack(alignment: .leading) {
                    Text("最近一次分析結果")
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                        .padding(.leading, 20)
                    
                    TeaDetail()
                }
                
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
