import UIKit

final class SelectionIndicatorView: UIView {
    
    var ovalLayer = CAShapeLayer()
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init() {
        super.init(frame: .zero)
        layer.addSublayer(ovalLayer)
        ovalLayer.fillColor = UIColor.white.cgColor
        ovalLayer.shadowColor = UIColor.lightGray.cgColor
        ovalLayer.shadowOffset = CGSize(width: 0.0, height: 8)
        ovalLayer.shadowOpacity = 0.2
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
            self.ovalLayer.isHidden = self.traitCollection.userInterfaceStyle == .dark
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let ovalFrameSize = CGSize(width: bounds.width, height: bounds.height * 0.3)
        let ovalFrameOrigin = CGPoint(x: (bounds.width - ovalFrameSize.width) / 2.0, y: (bounds.height - ovalFrameSize.height) / 2.4)
        
        ovalLayer.frame = CGRect(origin: ovalFrameOrigin, size: ovalFrameSize)
        ovalLayer.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: ovalFrameSize)).cgPath
    }
    
}
