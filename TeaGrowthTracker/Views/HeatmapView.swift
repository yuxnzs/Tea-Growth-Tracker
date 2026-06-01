import SwiftUI
import SwiftData

struct HeatmapView: View {
    @AppStorage("selectedToggle") var selectedToggle: Int = 1
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \TeaDisease.createdAt) var teaDiseases: [TeaDisease]
    @Query(sort: \SolvedTeaDisease.createdAt) var solvedDiseases: [SolvedTeaDisease]

    var body: some View {
        let diseaseData: [[Double]] = teaDiseases.compactMap {
            guard let lat = $0.latitude, let lng = $0.longitude else { return nil }
            return [lat, lng, 0.3]
        }

        let solvedData: [[Double]] = solvedDiseases.compactMap {
            guard let lat = $0.latitude, let lng = $0.longitude else { return nil }
            return [lat, lng, 0.3]
        }

        let centerLocation: [Double] = {
            if let coord = Config.teaGardenLocations[selectedToggle] {
                return [coord.latitude, coord.longitude]
            } else {
                return [24.9767, 121.6798] // 預設值
            }
        }()

        HeatmapWebViewRepresentable(diseaseData: diseaseData, solvedData: solvedData, farmLocation: centerLocation)
            .navigationTitle("病害熱力圖")
            .ignoresSafeArea()
    }
}

#Preview {
    HeatmapView()
        .modelContainer(for: [TeaDisease.self, SolvedTeaDisease.self])
}
