import UIKit
import DRUIKit

final class AddIngredientIconView: UIView {
    
    var circleLayer = CAShapeLayer()
    var verticalLineLayer = CAShapeLayer()
    var horizontalLineLayer = CAShapeLayer()
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init() {
        super.init(frame: .zero)
        layer.addSublayer(circleLayer)
        // TODO: - remove hardcoded color
        circleLayer.fillColor = UIColor(red: 240.0/255.0, green: 241.0/255.0, blue: 252.0/255.0, alpha: 1.0).cgColor
        
        circleLayer.addSublayer(verticalLineLayer)
        verticalLineLayer.fillColor = AppColor.brandPrimary.value.cgColor
        
        circleLayer.addSublayer(horizontalLineLayer)
        horizontalLineLayer.fillColor = AppColor.brandPrimary.value.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = min(bounds.width, bounds.height) * (64.0 / 76.0)
        
        let circleFrameSize = CGSize(width: size, height: size)
        let circleFrameOrigin = CGPoint(x: (bounds.width - circleFrameSize.width) / 2.0, y: (bounds.height - circleFrameSize.height) / 2.0)
        
        circleLayer.frame = CGRect(origin: circleFrameOrigin, size: circleFrameSize)
        circleLayer.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: circleFrameSize)).cgPath
        
        let verticalLineFrameSize = CGSize(width: 4.0, height: 24.0)
        let verticalLineFrameOrigin = CGPoint(x: (circleFrameSize.width - verticalLineFrameSize.width) / 2.0, y: (circleFrameSize.height - verticalLineFrameSize.height) / 2.0)
        
        verticalLineLayer.frame = CGRect(origin: verticalLineFrameOrigin, size: verticalLineFrameSize)
        verticalLineLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: verticalLineFrameSize), cornerRadius: verticalLineFrameSize.width / 2.0).cgPath
        
        let horizontalLineFrameSize = CGSize(width: 24.0, height: 4.0)
        let horizontalLineFrameOrigin = CGPoint(x: (circleFrameSize.width - horizontalLineFrameSize.width) / 2.0, y: (circleFrameSize.height - horizontalLineFrameSize.height) / 2.0)
        
        horizontalLineLayer.frame = CGRect(origin: horizontalLineFrameOrigin, size: horizontalLineFrameSize)
        horizontalLineLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: horizontalLineFrameSize), cornerRadius: verticalLineFrameSize.height / 2.0).cgPath
    }
}
