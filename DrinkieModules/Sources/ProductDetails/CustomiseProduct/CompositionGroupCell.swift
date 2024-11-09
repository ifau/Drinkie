import UIKit
import DRUIKit

protocol CompositionGroupCellModel {
    var localizedTitle: String { get }
    var localizedPrice: String { get }
}

final class CompositionGroupCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CompositionGroupCell"
    
    private lazy var compositionIcon: CompositionGroupIconView = {
        let view = CompositionGroupIconView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.relative(.regular, size: 14, relativeTo: .body)
        label.textColor = AppColor.textPrimary.value
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.relative(.regular, size: 12, relativeTo: .body)
        label.textColor = AppColor.brandPrimary.value
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [compositionIcon, titleLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        contentView.addSubview(mainStackView)
        contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.medium.value),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            //mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            compositionIcon.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            compositionIcon.heightAnchor.constraint(equalTo: compositionIcon.widthAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: mainStackView.bottomAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            priceLabel.heightAnchor.constraint(equalToConstant: Spacing.medium.value)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? CompositionGroupsCellAttributes else { return }
        
        guard let _ = titleLabel.text else { return }
        
        let distance = max(0, 1 - attributes.distanceFromCenter.magnitude)
        let scale = 1 + (0.2 * distance * attributes.transitionProgress)

        compositionIcon.transform = CGAffineTransformConcat(CGAffineTransform(scaleX: scale, y: scale), CGAffineTransform(translationX: 0, y: -16.0 * distance * attributes.transitionProgress))
        
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    func configure(with model: MutableCompositionGroup) {
        titleLabel.text = model.localizedTitle
        priceLabel.text = model.localizedPrice
        compositionIcon.ingredients = model.ingredients.filter({ $0.isSelected })
    }
}
