import UIKit
import DRUIKit

protocol IngredientCellModel {
    
    var localizedTitle: String { get }
    var localizedSubtitle: String { get }
    var isSelected: Bool { get }
    var isAvailable: Bool { get }
    var loadImage: (_ size: CGSize) async throws -> UIImage? { get }
}


final class IngredientCell: UICollectionViewCell {
    
    static let reuseIdentifier = "IngredientCell"
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.relative(.regular, size: 12, relativeTo: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.relative(.regular, size: 12, relativeTo: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = AppColor.backgoundPrimary.value
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DRUIKit.Spacing.small.value),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DRUIKit.Spacing.small.value),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor),
            
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DRUIKit.Spacing.small.value),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DRUIKit.Spacing.small.value),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DRUIKit.Spacing.medium.value)
        ])
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private var fetchTask: Task<(), Never>?
    
    override func prepareForReuse() {
        fetchTask?.cancel()
        fetchTask = nil
        super.prepareForReuse()
    }
    
    func configure(with model: any IngredientCellModel, showSubtitle: Bool) {
        titleLabel.text = model.localizedTitle
        titleLabel.textColor = model.isAvailable ? AppColor.textPrimary.value : AppColor.textSecondary.value
        
        subtitleLabel.text = model.localizedSubtitle
        subtitleLabel.textColor = model.isSelected ? AppColor.brandPrimary.value : AppColor.textSecondary.value
        
        subtitleLabel.isHidden = !showSubtitle
        
        imageView.alpha = model.isAvailable ? 1.0 : 0.5
        contentView.layer.borderWidth = model.isSelected ? 2.0 : 0.0
        contentView.layer.borderColor = model.isSelected ? AppColor.brandPrimary.value.cgColor : nil
        contentView.layer.cornerRadius = DRUIKit.CornerRadius.large.value
        
        fetchTask = Task {
            defer { fetchTask = nil }
            
            let image = try? await model.loadImage(CGSize(width: 200, height: 200))
            guard !Task.isCancelled else { return }
            imageView.image = image
        }
    }
}
