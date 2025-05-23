import Foundation

class DisplayManager: ObservableObject {
    @Published var isShowingTabBar = false
    @Published var showActionLoadingView = false
    @Published var hasNewDiseaseData = false
    @Published var needReloadHistoryPage = false
    @Published var needReloadMap = false
    @Published var isGardenChanged = true
}
