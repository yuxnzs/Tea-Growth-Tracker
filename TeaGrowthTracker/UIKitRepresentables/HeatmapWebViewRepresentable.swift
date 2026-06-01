import SwiftUI
import WebKit

struct HeatmapWebViewRepresentable: UIViewRepresentable {
    let diseaseData: [[Double]]
    let solvedData: [[Double]]
    let farmLocation: [Double]

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: Config.heatmapURL) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HeatmapWebViewRepresentable

        init(_ parent: HeatmapWebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.injectJS(into: webView)
        }
    }
    
    func injectJS(into webView: WKWebView) {
        guard
            let diseaseStr = try? JSONSerialization.data(withJSONObject: diseaseData),
            let solvedStr = try? JSONSerialization.data(withJSONObject: solvedData),
            let farmStr = try? JSONSerialization.data(withJSONObject: farmLocation),
            let diseaseJS = String(data: diseaseStr, encoding: .utf8),
            let solvedJS = String(data: solvedStr, encoding: .utf8),
            let farmJS = String(data: farmStr, encoding: .utf8)
        else {
            print("轉換失敗")
            return
        }

        let js = """
        window.diseaseData = \(diseaseJS);
        window.solvedData = \(solvedJS);
        window.farmLocation = \(farmJS);
        moveToFarm();
        fadeHeatLayerTo(window.diseaseData);
        """

        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("HeatmapWebViewRepresentable: JavaScript 注入失敗：\(error)")
            }
        }
    }
}
