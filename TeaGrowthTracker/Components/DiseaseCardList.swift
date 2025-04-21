import SwiftUI

struct DiseaseCardList<Model>: View where Model: Observable, Model: Identifiable {
    var teaDiseases: [Model]
    var buttonSystemName: String
    var buttonAction: (Model, Int) -> Void
    var deleteAction: (Model, Int) -> Void
    
    var body: some View {
        VStack {
            ForEach(Array(teaDiseases.enumerated()), id: \.element.id) { index, item in
                NavigationLink {
                    // 點卡片放大圖片
                    if let teaDisease = item as? TeaDisease {
                        FullImageView(
                            selectedTab: .constant(0),
                            isAnalysisView: false,
                            asyncImages: nil,
                            useUIImage: true,
                            uiImage: teaDisease.teaImage
                        )
                    } else if let solved = item as? SolvedTeaDisease {
                        FullImageView(
                            selectedTab: .constant(0),
                            isAnalysisView: false,
                            asyncImages: nil,
                            useUIImage: true,
                            uiImage: solved.teaImage
                        )
                    }
                } label: {
                    VStack {
                        if let teaDisease = item as? TeaDisease {
                            TeaDiseaseHistoryCardRepresentable(
                                teaImage: teaDisease.teaImage,
                                diseaseName: teaDisease.diseaseName,
                                confidenceLevel: teaDisease.confidenceLevel,
                                analysisDate: teaDisease.analysisDate
                            )
                        } else if let solved = item as? SolvedTeaDisease {
                            TeaDiseaseHistoryCardRepresentable(
                                teaImage: solved.teaImage,
                                diseaseName: solved.diseaseName,
                                confidenceLevel: solved.confidenceLevel,
                                analysisDate: solved.analysisDate
                            )
                        }
                    }
                    .padding(.bottom, 210)
                    // 刪除按鈕
                    .overlay(alignment: .topTrailing) {
                        Button {
                            DispatchQueue.main.async {
                                deleteAction(item, index)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .padding(7)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .padding(.trailing, 28)
                        .padding(.top, 8)
                    }
                    // 刪除旁按鈕
                    .overlay(alignment: .topTrailing) {
                        Button {
                            DispatchQueue.main.async {
                                buttonAction(item, index)
                            }
                        } label: {
                            Image(systemName: buttonSystemName)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.green)
                        }
                        .padding(7)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .padding(.trailing, 75)
                        .padding(.top, 8)
                    }
                }
            }
        }
    }
}

#Preview {
    DiseaseCardList(
        teaDiseases: [] as [TeaDisease],
        buttonSystemName: "checkmark",
        buttonAction: { _, _ in },
        deleteAction: { _, _ in }
    )
}
