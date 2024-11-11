import MapKit
import UIKit
import DRUIKit

final class UnitAnotationClusterView: MKAnnotationView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = AppFont.relative(.regular, size: 18, relativeTo: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = AppFont.relative(.regular, size: 16, relativeTo: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var titleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.brandPrimary.value
        return view
    }()
    
    private lazy var subtitleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.brandPrimary.value
        return view
    }()
    
    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        titleBackgroundView.addSubview(titleLabel)
        subtitleBackgroundView.addSubview(subtitleLabel)
        addSubview(titleBackgroundView)
        addSubview(subtitleBackgroundView)
        
        displayPriority = .defaultHigh
        collisionMode = .circle
        
        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        update()
    }
    
    func update() {
        guard let anotation = self.annotation as? MKClusterAnnotation else { return }
        titleLabel.text = "\(anotation.memberAnnotations.count)"
        
        let unitAnotation = anotation.memberAnnotations.compactMap { $0 as? UnitAnotation }.first
        subtitleLabel.text = unitAnotation?.unit.unit.address.cityName ?? " "
        
        let spacingAfterTitle = 2.0
        let titleSize = max(40.0, titleLabel.intrinsicContentSize.width, titleLabel.intrinsicContentSize.height)
        let subtitleWidth = subtitleLabel.intrinsicContentSize.width + Spacing.large.value
        let subtitleHeight = max(28.0, subtitleLabel.intrinsicContentSize.height)
        let totalWidth = max(titleSize, subtitleWidth)
        let totalHeight = titleSize + spacingAfterTitle + subtitleHeight
        
        titleBackgroundView.frame = CGRect(x: (totalWidth - titleSize) / 2.0, y: 0, width: titleSize, height: titleSize)
        titleLabel.frame = CGRect(x: 0, y: 0, width: titleSize, height: titleSize)
        titleBackgroundView.roundCorners(by: titleSize / 2.0)
        
        subtitleBackgroundView.frame = CGRect(x: (totalWidth - subtitleWidth) / 2.0, y: titleBackgroundView.frame.maxY + spacingAfterTitle, width: subtitleWidth, height: subtitleHeight)
        subtitleLabel.frame = CGRect(x: 0, y: 0, width: subtitleWidth, height: subtitleHeight)
        subtitleBackgroundView.roundCorners(by: subtitleHeight / 2.0)
        
        frame = CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
    }
}
