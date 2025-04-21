import SwiftUI

class HistoryLimitManager: ObservableObject {
    @Published var historyLimit: Int = 20
    @Published var currentHistoryCount: Int {
        // 當數值更新時，儲存到 UserDefaults
        didSet {
            UserDefaults.standard.set(currentHistoryCount, forKey: "currentHistoryCount")
        }
    }
    @Published var solvedHistoryCount: Int = 0
    @Published var currentSolvedHistoryCount: Int {
        // 當數值更新時，儲存到 UserDefaults
        didSet {
            UserDefaults.standard.set(currentSolvedHistoryCount, forKey: "currentSolvedHistoryCount")
        }
    }
    
    init() {
        // 從 UserDefaults 初始化 currentHistoryCount
        self.currentHistoryCount = UserDefaults.standard.integer(forKey: "currentHistoryCount")
        // 從 UserDefaults 初始化 currentSolvedHistoryCount
        self.currentSolvedHistoryCount = UserDefaults.standard.integer(forKey: "currentSolvedHistoryCount")
    }
    
    func hasReachedLimit() -> Bool {
        return currentHistoryCount >= historyLimit
    }
    
    func hasReachedSolvedLimit() -> Bool {
        return currentSolvedHistoryCount >= historyLimit
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
    
    // 增加 currentSolvedHistoryCount
    func incrementSolvedCount() {
        if currentSolvedHistoryCount < historyLimit {
            currentSolvedHistoryCount += 1
        }
    }
    
    // 減少 currentSolvedHistoryCount
    func decrementSolvedCount() {
        if currentSolvedHistoryCount > 0 {
            currentSolvedHistoryCount -= 1
        }
    }
}
