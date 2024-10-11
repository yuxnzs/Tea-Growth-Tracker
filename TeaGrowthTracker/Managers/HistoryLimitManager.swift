import SwiftUI

class HistoryLimitManager: ObservableObject {
    @Published var historyLimit: Int = 5
    
    func hasReachedLimit(diseaseCount: Int) -> Bool {
        return diseaseCount >= historyLimit
    }
}
