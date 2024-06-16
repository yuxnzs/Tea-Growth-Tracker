import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                // 透過 ZStack 設定頂部安全區域背景顏色，避免內容直接透過去
                ZStack(alignment: .top) {
                    ScrollView {
                        VStack(spacing: 35) {
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
                                            .foregroundStyle(.white)
                                            .padding(.trailing, 3)
                                        
                                        Text("阿文茶園")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                    }
                                    
                                    // 茶園位置
                                    HStack {
                                        Image(systemName: "location")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(.white)
                                            .padding(.trailing, 3)
                                        
                                        Text("新北市石碇區")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                        
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
                            .padding(.top, 20)
                            .padding(.bottom)
                            .padding(.horizontal)
                            .background(Color(red: 0.098, green: 0.412, blue: 0.235)) // #19693c
                            // 切底部圓角
                            .clipShape(UnevenRoundedRectangle(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 25,
                                bottomTrailingRadius: 25,
                                topTrailingRadius: 0
                            ))
                            
                            // 最近一次分析結果
                            VStack {
                                HStack {
                                    Text("最近一次分析結果")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.gray)
                                        .onTapGesture {
                                            
                                        }
                                }
                                .padding(.horizontal, 20)
                                
                                TeaDetail()
                            }
                            
                            
                            // 歷史分析結果
                            VStack {
                                HStack {
                                    Text("歷史分析結果")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.gray)
                                        .onTapGesture {
                                            
                                        }
                                }
                                .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(0..<5) { _ in
                                            RecentAnalysisPreview()
                                                .padding(.trailing, 15)
                                        }
                                    }
                                    .padding(.leading, 20)
                                }
                                
                            }
                        }
                        
                    }
                    
                    Color(red: 0.098, green: 0.412, blue: 0.235)
                        .frame(height: geometry.safeAreaInsets.top)
                        .ignoresSafeArea()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

