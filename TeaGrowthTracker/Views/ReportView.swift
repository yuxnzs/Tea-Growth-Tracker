import SwiftUI

struct ReportView: View {
    @State private var showReportAlert = false
    @State private var reportText = ""
    @State private var submittedText = ""

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Button("回報問題") {
                    showReportAlert = true
                }

                if !submittedText.isEmpty {
                    Text("你送出的內容：\(submittedText)")
                        .foregroundColor(.gray)
                }
            }

            if showReportAlert {
                Color.black.opacity(0.4) // 背景遮罩
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    Text("請輸入問題內容")
                        .font(.headline)

                    TextField("輸入問題...", text: $reportText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    HStack {
                        Button("取消") {
                            showReportAlert = false
                            reportText = ""
                        }

                        Spacer()

                        Button("送出") {
                            submittedText = reportText
                            reportText = ""
                            showReportAlert = false
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: 300)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
    }
}

#Preview {
    ReportView()
}
