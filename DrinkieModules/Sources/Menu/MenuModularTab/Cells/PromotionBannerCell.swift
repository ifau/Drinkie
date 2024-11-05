import UIKit
import DRUIKit

class PromotionBannerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PromotionBannerCell"
    
    // MARK: Private properties
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 24, relativeTo: .headline)
        label.textColor = AppColor.textPrimary.value
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 12, relativeTo: .subheadline)
        label.textColor = AppColor.textPrimary.value
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        view.axis = .vertical
        view.spacing = Spacing.small.value
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Required
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        contentView.addSubview(labelsStackView)
        
        NSLayoutConstraint.activate([
            labelsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.medium.value),
            labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.medium.value),
            labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            labelsStackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: Public methods
    
    func configure(promotionBanner: PromotionBanner, attributesProvider: MenuViewAttributesProvider?) {
        let attributes = attributesProvider?.promotionLinkAttributes(promotionBanner.promotionLink)
        titleLabel.text = attributes?.localizedTitle ?? ""
        subtitleLabel.text = "tap for more"
    }
}

