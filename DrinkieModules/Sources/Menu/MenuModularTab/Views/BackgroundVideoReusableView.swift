import UIKit
import DRUIKit

class BackgroundVideoReusableView: UICollectionReusableView {
    
    static let reuseIdentifier = "BackgroundVideoReusableView"
    static let kind = "BackgroundVideoReusableViewKind"
    
    private lazy var mediaView: DRMediaView = {
        let view = DRMediaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.mask = fadeMaskLayer
        return view
    }()
    
    private lazy var fadeMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        layer.locations = [0, 0.5, 1]
        return layer
    }()
    
    private var mediaViewAspectRatio: CGFloat = 1 {
        didSet {
            if let mediaViewAspectRatioConstraint = mediaViewAspectRatioConstraint { NSLayoutConstraint.deactivate([mediaViewAspectRatioConstraint])
            }
            mediaViewAspectRatioConstraint = mediaView.heightAnchor.constraint(equalTo: mediaView.widthAnchor, multiplier: mediaViewAspectRatio)
            mediaViewAspectRatioConstraint?.priority = .defaultHigh
            mediaViewAspectRatioConstraint?.isActive = true
        }
    }
    private var mediaViewAspectRatioConstraint: NSLayoutConstraint?
    
    private var fetchAttributesTask: Task<(), Never>?
    
    // MARK: Required
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(mediaView)
        let bottomConstraint = mediaView.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomConstraint
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fadeMaskLayer.frame = mediaView.bounds
    }
    
    override func prepareForReuse() {
        fetchAttributesTask?.cancel()
        pauseVideoPlayback()
        super.prepareForReuse()
    }
    
    func configure(with banner: Banner, attributesProvider: MenuViewAttributesProvider?) {
        
        var loadBannerPreviewImage: () async throws -> UIImage? = { nil }
        var loadBannerVideo: () async throws -> URL? = { nil }
        
        if let productLink = banner.productBanner?.productLink,
           let attributes = attributesProvider?.productLinkAttributes(productLink) {
            loadBannerPreviewImage = attributes.loadBannerPreviewImage
            loadBannerVideo = attributes.loadBannerVideo
        }

        if let promotionLink = banner.promotionBanner?.promotionLink,
           let attributes = attributesProvider?.promotionLinkAttributes(promotionLink) {
            loadBannerPreviewImage = attributes.loadBannerPreviewImage
            loadBannerVideo = attributes.loadBannerVideo
        }
        
        fetchAttributesTask = Task {
            defer { fetchAttributesTask = nil }

            let previewImage = try? await loadBannerPreviewImage()
            guard !Task.isCancelled else { return }
            mediaView.showImage(previewImage, contentMode: .scaleAspectFill)
            
            let localVideoURL = try? await loadBannerVideo()
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

