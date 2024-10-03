import SwiftUI

struct UserTeaImage: View {
    var loadedImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                if let loadedImage = loadedImage {
                    Image(uiImage: loadedImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    LoadingPlaceholder()
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 350)
            .clipped()
            
            if let loadedImage = loadedImage {
                FullScreenButton(
                    destination: FullImageView(
                        selectedTab: .constant(0),
                        isAnalysisView: false,
                        asyncImages: nil,
                        useUIImage: true,
                        uiImage: loadedImage
                    ),
                    isAnalysisView: false
                )
            }
        }
    }
}

#Preview {
    TeaLeafAnalysisView(photoPickerItem: nil, cameraImage: UIImage(named: "test"))
}
