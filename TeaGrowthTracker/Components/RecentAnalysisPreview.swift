import SwiftUI

struct RecentAnalysisPreview: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("tea-test")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 150)
            
            VStack {
                HStack {
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                    
                    Text("2024 / 06 / 01")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .padding(.leading, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 50)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 20)
        }
        .frame(width: 210, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    RecentAnalysisPreview()
        .padding()
}
