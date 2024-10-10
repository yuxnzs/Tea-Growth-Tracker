import SwiftUI

struct TeaGardenSelectorView: View {
    @EnvironmentObject var teaService: TeaService
    
    let teaGardens: [String] = ["綠山茶園", "香茗茶園", "霧嶺茶園", "翠嶺茶園"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(teaGardens.enumerated()), id: \.element) { index, teaGarden in
                    TeaGardenToggle(toggleId: index + 1, teaGardenName: teaGarden)
                }
            }
            .padding(.top, -35)
            .environmentObject(teaService)
            .navigationTitle("切換茶園")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TeaGardenSelectorView()
        .environmentObject(TeaService())
}
