import UIKit
import DRUIKit

class DefaultPromotionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DefaultPromotionCell"
    
    // MARK: Private properties
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 24, relativeTo: .headline)
        label.textColor = AppColor.textPrimary.value
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .natural
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = AppColor.brandPrimary.value
        configuration.baseForegroundColor = .white
        configuration.buttonSize = .large
        configuration.titlePadding = 0
        configuration.contentInsets = .init(top: 16, leading: 24, bottom: 16, trailing: 24)
        configuration.titleAlignment = .center
        let button = DRButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let actionButtonFont: UIFont = AppFont.relative(.regular, size: 22, relativeTo: .body)
    
    private var fetchAttributesTask: Task<(), Never>?
    
    // MARK: Required
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.roundCorners(by: CornerRadius.extraLarge.value)
        contentView.backgroundColor = AppColor.brandSecondary.value
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(actionButton)
        actionButton.roundCorners(by: CornerRadius.extraLarge.value)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        
        let actionButtonTrailing = actionButton.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: -Spacing.large.value)
        actionButtonTrailing.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.large.value),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large.value),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.large.value),
            
            actionButton.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: Spacing.small.value),
            actionButtonTrailing,
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large.value),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.large.value)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if actionButton.frame.height > 0 {
            actionButton.roundCorners(by: actionButton.frame.height / 2.0)
        }
    }
    
    override func prepareForReuse() {
        fetchAttributesTask?.cancel()
        super.prepareForReuse()
    }
    
    // MARK: Public methods
    
    func configure(promotionLink: PromotionLink, attributesProvider: MenuViewAttributesProvider?) {
        
        guard let attributes = attributesProvider?.promotionLinkAttributes(promotionLink) else { return }
        
        titleLabel.text = attributes.localizedTitle
        actionButton.configuration?.attributedTitle = AttributedString(attributes.actionLocalizedTitle ?? "", attributes: AttributeContainer([NSAttributedString.Key.font : actionButtonFont]))
        actionButton.isHidden = attributes.actionLocalizedTitle == nil
        
        fetchAttributesTask = Task {
            defer { fetchAttributesTask = nil }
            
            let imageWidth = max(imageView.frame.width, MenuView.Constants.defaultImageSize.width)
            let imageHeight = max(imageView.frame.height, MenuView.Constants.defaultImageSize.height)
            let image = try? await attributes.loadImage(CGSize(width: imageWidth, height: imageHeight))
            
            guard !Task.isCancelled else { return }
            imageView.image = image
        }
    }
}

