import UIKit
import SDWebImage

class TeaDiseaseHistoryCardViewController: UIViewController {
    let teaImage: UIImage
    let diseaseName: String
    let confidenceLevel: Double
    let analysisDate: String
    
    init(teaImage: UIImage, diseaseName: String, confidenceLevel: Double, analysisDate: String) {
        self.teaImage = teaImage
        self.diseaseName = diseaseName
        self.confidenceLevel = confidenceLevel
        self.analysisDate = analysisDate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        // 卡片 Container
        let cardContainer = UIView()
        cardContainer.layer.cornerRadius = 10
        cardContainer.clipsToBounds = true
        
        view.addSubview(cardContainer)
        
        // 設定 AutoLayout
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            cardContainer.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // 茶葉圖片
        let teaImageView = UIImageView()
        if let resizedImage = teaImage.resizeProportionally(toFit: CGSize(width: 1000, height: 1000)) {
            teaImageView.image = resizedImage
        }
        teaImageView.contentMode = .scaleAspectFill
        
        cardContainer.addSubview(teaImageView)
        
        // 設定 AutoLayout
        teaImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // 與父容器等寬等高
            teaImageView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            teaImageView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            teaImageView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            teaImageView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor)
        ])
        
        // 日期文字 Container
        let dateContainer = createBlurView()
        dateContainer.layer.cornerRadius = 15
        dateContainer.clipsToBounds = true
        
        // 日期文字
        let dateLabel = UILabel()
        dateLabel.text = analysisDate
        dateLabel.font = .systemFont(ofSize: 13, weight: .bold)
        dateLabel.textColor = .white
        dateLabel.layer.shadowColor = UIColor.black.cgColor
        dateLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        dateLabel.layer.shadowOpacity = 0.5
        dateLabel.layer.shadowRadius = 5
        
        cardContainer.addSubview(dateContainer)
        dateContainer.contentView.addSubview(dateLabel)
        
        // 設定 AutoLayout
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 左上角日期文字 Container
            dateContainer.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 8),
            dateContainer.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 8),
            // 日期文字 Padding
            dateLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor, constant: 7),
            dateLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor, constant: -7),
            dateLabel.topAnchor.constraint(equalTo: dateContainer.topAnchor, constant: 7),
            dateLabel.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor, constant: -7)
        ])
        
        // 底部資訊
        let infoContainer = createBlurView()
        let containerHeight: CGFloat = 45
        let exclamationMarkIcon = UIImageView()
        let diseaseName = UILabel()
        let confidenceLevel = UILabel()
        
        // Info Container 陰影效果
        infoContainer.layer.shadowColor = UIColor.black.cgColor // 陰影顏色
        infoContainer.layer.shadowOpacity = 0.35 // 陰影透明度
        infoContainer.layer.shadowOffset = CGSize(width: 0, height: 0) // 陰影偏移量設為 0，均勻效果
        infoContainer.layer.shadowRadius = 23 // 陰影半徑
        
        // 驚嘆號圖標
        exclamationMarkIcon.image = UIImage(systemName: "exclamationmark.triangle.fill")
        exclamationMarkIcon.tintColor = .white
        exclamationMarkIcon.contentMode = .scaleAspectFit
        exclamationMarkIcon.layer.shadowColor = UIColor.black.cgColor
        exclamationMarkIcon.layer.shadowOffset = CGSize(width: 1, height: 1)
        exclamationMarkIcon.layer.shadowOpacity = 0.5
        exclamationMarkIcon.layer.shadowRadius = 8
        
        // 疾病名稱與信心程度
        diseaseName.text = "\(self.diseaseName) •"
        confidenceLevel.text = String(format: "%.2f%%", self.confidenceLevel)
        [diseaseName, confidenceLevel].forEach {
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .white
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 1, height: 1)
            $0.layer.shadowOpacity = 0.6
            $0.layer.shadowRadius = 8
        }
        
        // 設定 AutoLayout
        infoContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(infoContainer)
        [exclamationMarkIcon, diseaseName, confidenceLevel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            infoContainer.contentView.addSubview($0)
            
            // Y 軸置中於 Info Container
            NSLayoutConstraint.activate([
                $0.centerYAnchor.constraint(equalTo: infoContainer.centerYAnchor)
            ])
        }
        
        NSLayoutConstraint.activate([
            // 底部資訊容器
            infoContainer.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            infoContainer.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            infoContainer.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
            infoContainer.heightAnchor.constraint(equalToConstant: containerHeight),
            
            // 驚嘆號圖標
            exclamationMarkIcon.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 15),
            exclamationMarkIcon.widthAnchor.constraint(equalToConstant: 17),
            exclamationMarkIcon.heightAnchor.constraint(equalToConstant: 17),
            
            // 疾病名稱
            diseaseName.leadingAnchor.constraint(equalTo: exclamationMarkIcon.trailingAnchor, constant: 7),
            
            // 信心程度
            confidenceLevel.leadingAnchor.constraint(equalTo: diseaseName.trailingAnchor, constant: 5)
        ])
    }
    
    private func createBlurView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }
}

#Preview {
    TeaDiseaseHistoryCardViewController(
        teaImage: UIImage(systemName: "leaf")!,
        diseaseName: "茶葉病害",
        confidenceLevel: 99.99,
        analysisDate: "2025-01-01"
    )
}
