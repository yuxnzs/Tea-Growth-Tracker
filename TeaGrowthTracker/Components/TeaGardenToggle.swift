import SwiftUI

struct TeaGardenToggle: View {
    @EnvironmentObject var teaService: TeaService
    
    let toggleId: Int
    let teaGardenName: String
    
    var body: some View {
        Toggle(isOn: toggleBinding) {
            Text(teaGardenName)
        }
        .padding(.vertical, 5)
    }
    
    private var toggleBinding: Binding<Bool> {
        Binding(
            // get：提供 Toggle 的狀態，true 表示 Toggle 被選中，false 表示未被選中
            // 如果自己的 toggleId 等於 TeaService 內的 selectedToggle，開啟 Toggle
            // 達成一次只能選擇一個 Toggle 的效果
            get: { teaService.selectedToggle == toggleId },
            // set：根據 Toggle 的新狀態（newValue）更新 selectedToggle
            // newValue 由 Toggle 的狀態決定（get 回傳的 true 或 false 值）
            // 用戶開啟 Toggle 時，newValue 為 true，關閉時，newValue 為 false
            set: { newValue in
                if newValue {
                    teaService.selectedToggle = toggleId // 用於控制 Toggle 按鈕的顯示、關閉狀態
                    teaService.id = "/\(toggleId)" // 更新 API 的 id 參數
                }
            }
        )
    }
}

#Preview {
    TeaGardenToggle(toggleId: 1, teaGardenName: "龍井茶園")
        .environmentObject(TeaService())
}
