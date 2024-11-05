import UIKit
import DRUIKit

class LargeVideoProductCell: UICollectionViewCell {
    
    static let reuseIdentifier = "LargeVideoProductCell"
    
    private lazy var mediaView: DRMediaView = {
        let view = DRMediaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 16, relativeTo: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 14, relativeTo: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        view.axis = .vertical
        view.spacing = Spacing.medium.value
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .black
        configuration.baseForegroundColor = .white
        configuration.buttonSize = .medium
        
        let font: UIFont = AppFont.fixed(.regular, size: 24)
        configuration.attributedTitle = AttributedString("+", attributes: AttributeContainer([NSAttributedString.Key.font : font]))
        
        configuration.titlePadding = 0
        configuration.contentInsets = .zero
        configuration.titleAlignment = .center
        let button = DRButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var fetchAttributesTask: Task<(), Never>?
    
    // MARK: Required
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.roundCorners(by: CornerRadius.large.value)
        contentView.addSubview(mediaView)
        contentView.addSubview(labelsStackView)
        contentView.addSubview(actionButton)
        
        actionButton.layer.cornerRadius = 16.0
        actionButton.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mediaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DRUIKit.Spacing.large.value),
            labelsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DRUIKit.Spacing.medium.value),
            labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DRUIKit.Spacing.medium.value),
            
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DRUIKit.Spacing.medium.value),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DRUIKit.Spacing.medium.value),
            actionButton.widthAnchor.constraint(equalToConstant: 32),
            actionButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        fetchAttributesTask?.cancel()
        pauseVideoPlayback()
        super.prepareForReuse()
    }
    
    func configure(productLink: ProductLink, attributesProvider: MenuViewAttributesProvider?) {
        
        guard let attributes = attributesProvider?.productLinkAttributes(productLink) else { return }
        titleLabel.text = attributes.localizedTitle
        priceLabel.text = attributes.localizedPrice

        fetchAttributesTask = Task {
            defer { fetchAttributesTask = nil }

            let previewImage = try? await attributes.loadBannerPreviewImage()
            guard !Task.isCancelled else { return }
            mediaView.showImage(previewImage, contentMode: .scaleAspectFill)
            
            let localVideoURL = try? await attributes.loadBannerVideo()
            guard !Task.isCancelled else { return }
            
            if let localVideoURL {
                mediaView.showImage(nil)
                mediaView.showVideo(url: localVideoURL)
                mediaView.resumeVideoPlayback()
            }
        }
    }
    
    func resumeVideoPlayback() {
        mediaView.resumeVideoPlayback()
    }
    
    func pauseVideoPlayback() {
        mediaView.pauseVideoPlayback()
    }
}

