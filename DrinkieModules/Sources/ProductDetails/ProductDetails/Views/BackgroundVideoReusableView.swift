import UIKit
import DRUIKit
import Combine

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
        layer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
        layer.locations = [0, 0.5, 0.7, 1]
        return layer
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 20, relativeTo: .headline)
        label.textColor = AppColor.textPrimary.value
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
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
    
    private var loadBannerVideoTask: Task<(), Never>?
    private var selectedProductSubscription: AnyCancellable?
    private var previouslyFinishedLoadVideo = false
    
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
        
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fadeMaskLayer.frame = mediaView.bounds
        
        let titleWidth = bounds.width - Spacing.large.value * 2
        var titleHeight = titleLabel.intrinsicContentSize.height
        if let text = titleLabel.text, let font = titleLabel.font {
            titleHeight = text.boundingRect(with: CGSize(width: titleWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil).size.height
        }
        
        let layoutConfiguration = ProductDetailsCollectionViewLayout.Configuration()
        let y = layoutConfiguration.actionHeaderTopPaddingRatio * bounds.height - titleHeight
        titleLabel.frame.size = CGSize(width: titleWidth, height: titleHeight)
        titleLabel.frame.origin = CGPoint(x: Spacing.large.value, y: y)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? ProductDetailsCellAttributes else { return }
        
        titleLabel.alpha = max(0, (0.6 - attributes.transitionProgress) / 0.6)
    }
    
    override func prepareForReuse() {
        loadBannerVideoTask?.cancel()
        loadBannerVideoTask = nil
        pauseVideoPlayback()
        previouslyFinishedLoadVideo = false
        super.prepareForReuse()
    }
    
    func configure(viewModel: ActionHeaderViewModel) {
        
        selectedProductSubscription = viewModel
            .$selectedProduct
            .sink { [weak self, weak viewModel] selectedProduct in
                guard let self, let viewModel else { return }
                guard !previouslyFinishedLoadVideo else { return }
                
                titleLabel.text = selectedProduct?.name
                loadBannerUsing(loadPreviewImage: viewModel.loadBannerPreviewImage, loadVideo: viewModel.loadBannerVideo)
            }
    }
    
    private func loadBannerUsing(loadPreviewImage: @escaping () async throws -> UIImage?,
                                 loadVideo: @escaping () async throws -> URL?) {
        
        loadBannerVideoTask = Task { @MainActor in
            defer { loadBannerVideoTask = nil }
            
            if let previewImage = try? await loadPreviewImage() {
                guard !Task.isCancelled else { return }
                
                mediaViewAspectRatio = previewImage.size.height / previewImage.size.width
                mediaView.showImage(previewImage, contentMode: .scaleAspectFill)
            }
            
            if let localVideoURL = try? await loadVideo() {
                guard !Task.isCancelled else { return }
                mediaView.showImage(nil)
                mediaView.showVideo(url: localVideoURL, videoGravity: .resizeAspectFill)
                mediaView.resumeVideoPlayback()
                previouslyFinishedLoadVideo = true
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

