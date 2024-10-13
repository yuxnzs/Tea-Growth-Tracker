import SwiftUI
import PhotosUI

struct TeaGardenInfoBar: View {
    @EnvironmentObject var teaService: TeaService
    @Binding var isTeaGardenSelectorViewPresented: Bool
    @Binding var needsRefreshData: Bool
    @Binding var isHistoryLoading: Bool
    @Binding var showHistoryPage: Bool
    @Binding var isCameraLoading: Bool
    @Binding var showOptions: Bool
    @Binding var showPhotoPicker: Bool
    @Binding var showCamera: Bool
    @Binding var photoPickerItem: PhotosPickerItem?
    @Binding var cameraImage: UIImage?
    @Binding var showAnalysisPage: Bool
    
    let teaGardenName: String
    let teaGardenLocation: String
    let isPlaceholder: Bool
    
    // 如果 isPlaceholder 為 true，只需要傳入茶園名稱與位置，其他參數設為 false 或 nil
    init(
        isTeaGardenSelectorViewPresented: Binding<Bool> = .constant(false),
        needsRefreshData: Binding<Bool> = .constant(false),
        isHistoryLoading: Binding<Bool> = .constant(false),
        showHistoryPage: Binding<Bool> = .constant(false),
        isCameraLoading: Binding<Bool> = .constant(false),
        showOptions: Binding<Bool> = .constant(false),
        showPhotoPicker: Binding<Bool> = .constant(false),
        showCamera: Binding<Bool> = .constant(false),
        photoPickerItem: Binding<PhotosPickerItem?> = .constant(nil),
        cameraImage: Binding<UIImage?> = .constant(nil),
        showAnalysisPage: Binding<Bool> = .constant(false),
        teaGardenName: String,
        teaGardenLocation: String,
        isPlaceholder: Bool = false
    ) {
        self._isTeaGardenSelectorViewPresented = isTeaGardenSelectorViewPresented
        self._needsRefreshData = needsRefreshData
        self._isHistoryLoading = isHistoryLoading
        self._showHistoryPage = showHistoryPage
        self._isCameraLoading = isCameraLoading
        self._showOptions = showOptions
        self._showPhotoPicker = showPhotoPicker
        self._showCamera = showCamera
        self._photoPickerItem = photoPickerItem
        self._cameraImage = cameraImage
        self._showAnalysisPage = showAnalysisPage
        self.teaGardenName = teaGardenName
        self.teaGardenLocation = teaGardenLocation
        self.isPlaceholder = isPlaceholder
    }
    
    var body: some View {
        teaInfoBar()
            .opacity(isPlaceholder ? 0 : 1)
    }
    
    func teaInfoBar() -> some View {
        // 頂部資訊欄
        HStack {
            // 文字資訊
            VStack(spacing: 20) {
                // 茶園名稱
                HStack {
                    Image("pin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.white)
                        .padding(.trailing, 3)
                        .padding(.leading, -3)
                    
                    Text(teaGardenName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                // 點擊茶園名稱切換茶園
                .onTapGesture {
                    isTeaGardenSelectorViewPresented.toggle()
                }
                .sheet(isPresented: $isTeaGardenSelectorViewPresented, onDismiss: {
                    // 關閉時，獲取新的茶園資料
                    needsRefreshData = true
                }) {
                    TeaGardenSelectorView()
                        .environmentObject(teaService)
                        .presentationDetents([.fraction(0.45)])
                }
                
                // 茶園位置
                HStack {
                    Image(systemName: "location.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                        .padding(.trailing, 3)
                    
                    Text(teaGardenLocation)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
            }
            // 茶圖標
            VStack {
                Image("leaf")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 65, height: 65)
            }
            // 點擊茶圖標後顯示選擇相機或相簿
            .onTapGesture {
                showOptions = true
            }
            .overlay {
                PhotoSelectionButton(
                    showHistoryButton: .constant(true),
                    isHistoryLoading: $isHistoryLoading,
                    showHistoryPage: $showHistoryPage,
                    isCameraLoading: $isCameraLoading,
                    showOptions: $showOptions,
                    showPhotoPicker: $showPhotoPicker,
                    showCamera: $showCamera,
                    photoPickerItem: $photoPickerItem,
                    cameraImage: $cameraImage,
                    onPhotoPickerItemChange: { newItem in
                        if newItem != nil {
                            showAnalysisPage = true
                        }
                    },
                    onSelectedImageChange: { newImage in
                        if newImage != nil {
                            showAnalysisPage = true
                        }
                    }
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(.bottom)
        .padding(.horizontal)
        .background(Color(red: 0.098, green: 0.412, blue: 0.235)) // #19693c
        // 切底部圓角
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 25,
            bottomTrailingRadius: 25,
            topTrailingRadius: 0
        ))
    }
}

#Preview {
    TeaGardenInfoBar(
        isTeaGardenSelectorViewPresented: .constant(false),
        needsRefreshData: .constant(false),
        isHistoryLoading: .constant(false),
        showHistoryPage: .constant(false),
        isCameraLoading: .constant(false),
        showOptions: .constant(false),
        showPhotoPicker: .constant(false),
        showCamera: .constant(false),
        photoPickerItem: .constant(nil),
        cameraImage: .constant(nil),
        showAnalysisPage: .constant(false),
        teaGardenName: "綠山茶園",
        teaGardenLocation: "新北市石碇區"
    )
}
