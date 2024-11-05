import UIKit
import DRUIKit

class SectionHeaderReusableView: UICollectionReusableView {
    
    static let reuseIdentifier = "SectionHeaderReusableView"
    static let kind = "SectionHeaderReusableViewKind"
    
    // MARK: Private properties
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 20, relativeTo: .headline)
        label.textColor = AppColor.textPrimary.value
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: Required
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.medium.value),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Spacing.medium.value),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with text: String) {
        titleLabel.text = text
    }
}

