import SwiftUI

class HistoryLimitManager: ObservableObject {
    @Published var historyLimit: Int = 20
    @Published var currentHistoryCount: Int {
        // 當數值更新時，儲存到 UserDefaults
        didSet {
            UserDefaults.standard.set(currentHistoryCount, forKey: "currentHistoryCount")
        }
    }
    
    init() {
        // 從 UserDefaults 初始化 currentHistoryCount
        self.currentHistoryCount = UserDefaults.standard.integer(forKey: "currentHistoryCount")
    }
    
    func hasReachedLimit() -> Bool {
        return currentHistoryCount >= historyLimit
    }
    
    // 增加 currentHistoryCount
    func incrementCount() {
        if currentHistoryCount < historyLimit {
            currentHistoryCount += 1
        }
    }
    
    // 減少 currentHistoryCount
    func decrementCount() {
        if currentHistoryCount > 0 {
            currentHistoryCount -= 1
        }
    }
    
}
