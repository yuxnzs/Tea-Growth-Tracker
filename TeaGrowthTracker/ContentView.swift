import SwiftUI

struct ContentView: View {
    @StateObject var historyLimitManager = HistoryLimitManager()
    @StateObject var displayManager = DisplayManager()
    
    var body: some View {
        TabView {
            HomepageView(bottomPadding: 20)
                .environmentObject(historyLimitManager)
                .environmentObject(displayManager)
                .tabItem {
                    Label("首頁", systemImage: "house")
                }
                .toolbar(displayManager.isShowingTabBar ? .visible : .hidden, for: .tabBar)
            
            TeaDiseaseHistoryView(bottomPadding: 10, showTabBar: true)
                .environmentObject(historyLimitManager)
                .environmentObject(displayManager)
                .tabItem {
                    Label("歷史", systemImage: "clock")
                }
                .toolbar(displayManager.isShowingTabBar ? .visible : .hidden, for: .tabBar)
            
            TeaDiseaseMapView()
                .environmentObject(displayManager)
                .tabItem {
                    Label("地圖", systemImage: "map")
                }
                .toolbar(displayManager.isShowingTabBar ? .visible : .hidden, for: .tabBar)
        }
        .overlay {
            if displayManager.showActionLoadingView {
                ActionLoadingView()
            }
        }
    }
}

#Preview {
    ContentView()
}
