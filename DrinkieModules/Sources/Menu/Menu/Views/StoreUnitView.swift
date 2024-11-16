import UIKit
import DRUIKit
import DRAPI

final class StoreUnitView: UIView {
    
    private let imageSize = CGSize(width: 48, height: 48)
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.relative(.regular, size: 16, relativeTo: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.relative(.regular, size: 12, relativeTo: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillEqually
        return view
    }()
    
    override var intrinsicContentSize: CGSize {
        let width = imageSize.width + max(titleLabel.intrinsicContentSize.width, subtitleLabel.intrinsicContentSize.width) + Spacing.small.value
        let height = max(imageSize.height, (titleLabel.intrinsicContentSize.height + subtitleLabel.intrinsicContentSize.height + labelStackView.spacing))
        return CGSize(width: width, height: height)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init() {
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(labelStackView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        [
            labelStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Spacing.small.value),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            imageView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: imageSize.height)
        ].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure(storeUnit: StoreUnit) {
        
        // TODO: localisation
        var imageName: String
        var description: String
        switch storeUnit.schedule.openStatus(relaitiveTo: .now) {
        case .openUntil(_, let time):
            let hour = time.hour.formatted(.number.precision(.integerLength(2)))
            let minutes = time.minute.formatted(.number.precision(.integerLength(2)))
            description = "till \(hour):\(minutes)"
            imageName = "leaf.fill"
                
        case .closedUntil(_, let time):
            let hour = time.hour.formatted(.number.precision(.integerLength(2)))
            let minutes = time.minute.formatted(.number.precision(.integerLength(2)))
            description = "Open at \(hour):\(minutes)"
            imageName = "moon.stars.fill"
            
        case .unknown:
            description = "closed"
            imageName = "moon.stars.fill"
        }
        
        titleLabel.text = storeUnit.alias
        subtitleLabel.text = description
        
        let colorsConfig = UIImage.SymbolConfiguration(paletteColors: [AppColor.brandPrimary.value])
        let sizeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        imageView.image = UIImage(systemName: imageName, withConfiguration: colorsConfig.applying(sizeConfig))
    }
}
