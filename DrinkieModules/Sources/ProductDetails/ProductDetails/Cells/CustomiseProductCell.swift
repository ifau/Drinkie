import UIKit
import DRUIKit

class CustomiseProductCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CustomiseProductCell"
    
    // MARK: Private properties
    
    private lazy var customiseView: CustomiseProductView = {
        let view = CustomiseProductView()
        return view
    }()
    
    // MARK: Required
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(customiseView)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customiseView.frame = contentView.bounds
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? ProductDetailsCellAttributes else { return }
        customiseView.transitionProgress = attributes.transitionProgress
    }
    
    func configure(viewModel: CustomiseProductViewModel) {
        customiseView.viewModel = viewModel
    }
}
