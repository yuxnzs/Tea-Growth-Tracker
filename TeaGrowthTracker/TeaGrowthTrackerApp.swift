import SwiftUI
import SwiftData

@main
struct TeaGrowthTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [TeaDisease.self, SolvedTeaDisease.self])
        }
    }
}
