import UIKit
import DRUIKit

class IngredientsHeaderReusableView: UICollectionReusableView {
    
    static let reuseIdentifier = "IngredientsHeaderReusableView"
    static let kind = "IngredientsHeaderReusableViewKind"
    
    // MARK: Private properties
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 20, relativeTo: .headline)
        label.textColor = AppColor.textPrimary.value
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: Required
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            titleLabel.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with text: String) {
        titleLabel.text = text
    }
}

