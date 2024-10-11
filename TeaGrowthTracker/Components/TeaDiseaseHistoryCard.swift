import SwiftUI

struct TeaDiseaseHistoryCard: View {
    let teaImage: UIImage
    let diseaseName: String
    let confidenceLevel: Double
    let analysisDate: String
    let onDelete: () -> Void
    
    var body: some View {
        NavigationStack {
            NavigationLink {
                FullImageView(
                    selectedTab: .constant(0),
                    isAnalysisView: false,
                    asyncImages: nil,
                    useUIImage: true,
                    uiImage: teaImage
                )
            } label: {
                VStack {
                    // 使用縮小後的圖片進行顯示，避免圖片過大造成卡頓
                    if let resizedImage = teaImage.resizeProportionally(toFit: CGSize(width: 200, height: 200)) {
                        Image(uiImage: resizedImage)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                // 左上角日期
                .overlay(alignment: .topLeading) {
                    Text(analysisDate)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(7)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.leading, 8)
                        .padding(.top, 8)
                }
                // 右上角刪除按鈕
                .overlay(alignment: .topTrailing) {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding(7)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
                    .padding(.top, 8)
                }
                // 底部資訊
                .overlay(alignment: .bottomLeading) {
                    VStack {
                        HStack(spacing: 0) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .padding(.trailing, 7)
                            
                            Text("\(diseaseName) •")
                                .padding(.trailing, 5)
                            
                            
                            Text("\(String(format: "%.2f", confidenceLevel))%")
                        }
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 3)
                    }
                    .padding(.leading, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 45)
                    .background(.ultraThinMaterial)
                    .shadow(radius: 20)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
            }
        }
        .buttonStyle(.plain)
    }
}
