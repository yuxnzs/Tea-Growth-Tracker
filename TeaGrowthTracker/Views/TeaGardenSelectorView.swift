import SwiftUI

struct TeaGardenSelectorView: View {
    @EnvironmentObject var teaService: TeaService
    
    var body: some View {
        NavigationStack {
            List {
                TeaGardenToggle(toggleId: 1, teaGardenName: "龍井茶園")
                TeaGardenToggle(toggleId: 2, teaGardenName: "香茗茶園")
                TeaGardenToggle(toggleId: 3, teaGardenName: "綠山茶圓")
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
