import UIKit
import DRUIKit

final class StoreUnitView: UIView {
    
    private lazy var imageView: UIImageView = {
        let colorsConfig = UIImage.SymbolConfiguration(paletteColors: [AppColor.brandPrimary.value])
        let sizeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let image = UIImage(systemName: "leaf.fill", withConfiguration: colorsConfig.applying(sizeConfig))
        
        let view = UIImageView(image: image)
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
        let width = imageView.intrinsicContentSize.width + max(titleLabel.intrinsicContentSize.width, subtitleLabel.intrinsicContentSize.width) + Spacing.small.value
        let height = max(imageView.intrinsicContentSize.height, (titleLabel.intrinsicContentSize.height + subtitleLabel.intrinsicContentSize.height + labelStackView.spacing))
        return CGSize(width: width, height: height)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init() {
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(labelStackView)
        
        titleLabel.text = "Coffee shop"
        subtitleLabel.text = "till 20:00"
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0),
            
            labelStackView.topAnchor.constraint(equalTo: topAnchor),
            //labelStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Spacing.small.value),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let contraint = labelStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Spacing.small.value)
        contraint.priority = .defaultHigh
        contraint.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        labelStackView.spacing = 2.0
    }
}
