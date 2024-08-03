# 茶園監測 App 🌿

![App Poster](./assets/poster.png)
![App Interface](./assets/app_interface.png)

> 注意：此專題內所用之茶園名稱僅供示意，非真實茶園名稱，四個茶園均於石碇拍攝。

本專題榮獲「112 年度教育部人文社會永續行動創新應用競賽」優選（第一名）🏆，並獲得新聞媒體報導。在本專題中，我負責 `Swift` 前端、`Express` 後端及 `MongoDB` 資料庫等程式開發工作。

## 相關報導 📰

- [石碇高中生攜手致理科大用無人機及 AI 助茶農 獲教育部首屆永續行動創新獎](https://news.ltn.com.tw/news/life/breakingnews/4752180)（本人位於圖左 3）
- [人文社會永續行動創新應用競賽 跨域展關懷](https://tw.news.yahoo.com/人文社會永續行動創新應用競賽-跨域展關懷-095234806.html)

## 專案介紹 🌐

「茶園監測 App」是一款專為茶農設計的應用程式，使茶農能夠透過手機查看本團隊拍攝及分析後的茶園影像。這款 App 使用 `Swift` 開發前端，`JavaScript` 開發後端，並由 `Python` 進行影像分析和 `Microsoft Azure` 的自訂視覺服務進行影像辨識，為茶農提供關於茶園生長情形數據和種植程度分析。透過這樣的技術整合，茶農能夠利用科技輔助茶園的日常管理。

## 專案展示 🖥

https://github.com/user-attachments/assets/5ebafdff-781a-4dcc-aa02-189b66c3fc19

## 專案分工 🤝

- **無人機影像拍攝**：外聘無人機教練指導拍攝
- **App 介面設計與開發**：我負責整體 UI 設計與 `Swift / SwiftUI` 程式碼撰寫
- **後端 API 與資料庫設計**：我負責 `Express` API 架設與 `MongoDB` 資料庫設計
- **AI 模型訓練**：我負責訓練 `Microsoft Azure` 自訂視覺服務模型
- **影像分析**：其他組員與老師共同完成，使用 `Python` 的 `OpenCV` 和 `NumPy` 進行影像分析
- **後端及資料庫部署**：我負責將後端部署至 `Vercel` 並將資料庫部署至 `MongoDB Atlas`

## 使用技術 🔧

- **Swift**：進行邏輯撰寫，並使用以下關鍵功能
  - **URLSession**：處理網路請求
  - **Codable**：定義 JSON 資料的模型結構
  - **JSONDecoder**：解析 JSON 資料
- **SwiftUI**：進行狀態管理與建立使用者介面，並使用如 `@State`、`@Binding`、`@StateObject`、`@Published`、`@EnvironmentObject` 等屬性監聽狀態變化與在不同 View 間傳遞資料

## 功能 🚀

- **茶園狀況**：查看所有歷史分析紀錄，包含每次拍攝與分析後的生長率參考值及種植程度等資訊
- **茶園影像**：查看無人機原始所拍攝之茶園影像
- **分析影像**：查看 `Python` 分析後圖片與 `Microsoft Azure` 自訂視覺服務辨識出的種植程度低區域
- **茶園切換**：切換不同茶園的資訊

## 未來功能與改進 ✨

- **重構 JSON 資料模型**：移除不必要的 `TeaDecodeData` 結構，直接使用 `TeaData` 結構，減少程式碼複雜度，提升可讀性

## 後端程式碼 ⚙️

- [茶園監測系統後端](https://github.com/yuxnzs/Tea-Backend)

## 圖示來源 🌟

- [Location icons created by kmg design - Flaticon](https://www.flaticon.com/free-icons/location)
- [Nature icons created by Tanah Basah - Flaticon](https://www.flaticon.com/free-icons/nature)
