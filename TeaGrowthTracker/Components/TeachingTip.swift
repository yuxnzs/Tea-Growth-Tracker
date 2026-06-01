import TipKit

struct TeachingTip: Tip {
    @Parameter
    static var didTapShowTip: Bool = true
    
    var title: Text {
        Text("教學提示")
    }
    
    var message: Text? {
        Text("你可以點擊左側的 ✅ 圖示來標記紀錄為已解決，或是右側按鈕刪除紀錄。")
    }
    
    var image: Image? {
        Image(systemName: "lightbulb")
    }
    
    var rules: [Rule] {
        #Rule(Self.$didTapShowTip) { $0 == true }
    }
    
    var options: [Option] {
        [IgnoresDisplayFrequency(true)]
    }
}
