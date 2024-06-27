import SwiftUI

struct TeaGardenSelectorView: View {
    @EnvironmentObject var teaService: TeaService
    
    let teaGardens: [String] = ["龍井茶園", "香茗茶園", "綠山茶園", "翠嶺茶園"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(teaGardens.enumerated()), id: \.element) { index, teaGarden in
                    TeaGardenToggle(toggleId: index + 1, teaGardenName: teaGarden)
                }
            }
            .environmentObject(teaService)
            .navigationTitle("切換茶園")
        }
    }
}

#Preview {
    TeaGardenSelectorView()
        .environmentObject(TeaService())
}
