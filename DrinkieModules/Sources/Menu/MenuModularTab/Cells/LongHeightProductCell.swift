import UIKit
import DRUIKit

class LongHeightProductCell: UICollectionViewCell {
    
    static let reuseIdentifier = "LongHeightProductCell"
    
    // MARK: Private properties
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 12, relativeTo: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 12, relativeTo: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var accessoryImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: AppFont.relative(.regular, size: 14, relativeTo: .footnote))
        imageView.tintColor = AppColor.textSecondary.value
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        return imageView
    }()
    
    private lazy var priceStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [priceLabel, accessoryImageView])
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        view.spacing = DRUIKit.Spacing.small.value
        return view
    }()
    
    private lazy var flexibleSpaceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }()
    
    private lazy var labelStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, flexibleSpaceView, priceStackView])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var fetchAttributesTask: Task<(), Never>?
    
    // MARK: Required
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.roundCorners(by: CornerRadius.large.value)
        contentView.backgroundColor = AppColor.backgoundPrimary.value
        
        contentView.addSubview(imageView)
        contentView.addSubview(labelStackView)
        
        let imageViewAspectRatioConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0)
        imageViewAspectRatioConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            labelStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Spacing.small.value),
            labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.medium.value),
            labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.medium.value),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.small.value),
            
            imageViewAspectRatioConstraint,
            flexibleSpaceView.heightAnchor.constraint(greaterThanOrEqualToConstant: Spacing.small.value)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        fetchAttributesTask?.cancel()
        super.prepareForReuse()
    }
    
    func attributedTitle(from text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.4
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
    // MARK: Public methods
    
    func configure(productLink: ProductLink, attributesProvider: MenuViewAttributesProvider?) {
        
        guard let attributes = attributesProvider?.productLinkAttributes(productLink) else { return }
        
        if attributes.isAvailable {
            titleLabel.attributedText = attributedTitle(from: attributes.localizedTitle)
            titleLabel.alpha = 1.0
            imageView.alpha = 1.0
            accessoryImageView.isHidden = false
            priceLabel.text = attributes.localizedPrice
        } else {
            titleLabel.attributedText = attributedTitle(from: attributes.localizedTitle)
            titleLabel.alpha = 0.5
            imageView.alpha = 0.5
            accessoryImageView.isHidden = true
            priceLabel.text = "Sold out"
        }
        
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
