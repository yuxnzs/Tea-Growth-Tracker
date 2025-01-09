import SwiftUI

class HistoryLimitManager: ObservableObject {
    @Published var historyLimit: Int = 20
    
    func hasReachedLimit(diseaseCount: Int) -> Bool {
        return diseaseCount >= historyLimit
    }
}
