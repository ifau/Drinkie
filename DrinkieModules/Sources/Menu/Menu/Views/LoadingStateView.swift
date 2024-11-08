import Foundation
import UIKit
import DRUIKit

final class LoadingStateView: UIView {
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var logoView: UIView = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "drinkit"
        view.font = AppFont.fixed(.regular, size: 43)
        view.textAlignment = .center
        return view
    }()
    
    private lazy var bannerTemplate: UIView = {
        let view1 = createView(width: 80, height: 12, cornerRadius: 6)
        let centerView = createView(width: 190, height: 24, cornerRadius: 12)
        let view2 = createView(width: 40, height: 12, cornerRadius: 6)
        
        let container = UIStackView(arrangedSubviews: [view1, centerView, view2])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        container.alignment = .center
        container.spacing = Spacing.small.value
        return container
    }()
    
    private lazy var selectedTabIndicatorTemplate: UIView = {
        let view1 = createView(width: 80, height: 20, cornerRadius: 10)
        let view2 = createView(width: 80, height: 20, cornerRadius: 10)
        let view3 = createView(width: 80, height: 20, cornerRadius: 10)
        let view4 = createView(width: 80, height: 20, cornerRadius: 10)

        let container = UIStackView(arrangedSubviews: [view1, view2, view3, view4])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .horizontal
        container.distribution = .fillEqually
        container.spacing = Spacing.large.value
        return container
    }()
    
    private lazy var menuSectionTemplate: UIView = {
        let view1 = createView(cornerRadius: DRUIKit.CornerRadius.large.value)
        let view2 = createView(cornerRadius: DRUIKit.CornerRadius.large.value)
        
        let container = UIStackView(arrangedSubviews: [view1, view2])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .horizontal
        container.distribution = .fillEqually
        container.spacing = Spacing.medium.value
        return container
    }()
    
    private lazy var animationLayer: CAGradientLayer = {
        let gradientColorOne = AppColor.textPrimary.value.withAlphaComponent(0.05).cgColor
        let gradientColorTwo = AppColor.textPrimary.value.withAlphaComponent(0.1).cgColor
        let animationSpeed = 2.0
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = animationSpeed
        
        gradientLayer.add(animation, forKey: animation.keyPath)
        
        return gradientLayer
    }()
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = AppColor.backgroundSecondary.value
        
        addSubview(contentView)
        contentView.addSubview(logoView)
        contentView.addSubview(bannerTemplate)
        contentView.addSubview(selectedTabIndicatorTemplate)
        contentView.addSubview(menuSectionTemplate)
        activateConstraints()
        
        layer.addSublayer(animationLayer)
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
            
            let gradientColorOne = AppColor.textPrimary.value.withAlphaComponent(0.05).cgColor
            let gradientColorTwo = AppColor.textPrimary.value.withAlphaComponent(0.1).cgColor
            self.animationLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animationLayer.frame = frame
        animationLayer.mask = contentView.layer
    }
    
    private func activateConstraints() {
        var constraints: [NSLayoutConstraint] = []
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        constraints.append(contentsOf: [
            logoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            logoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            NSLayoutConstraint(item: logoView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: (MenuView.Constants.tabContentOffsetMultiplier / 2), constant: 1)
        ])
        constraints.append(contentsOf: [
            bannerTemplate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: DRUIKit.Spacing.large.value),
            bannerTemplate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -DRUIKit.Spacing.large.value),
            NSLayoutConstraint(item: bannerTemplate, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: MenuView.Constants.tabContentOffsetMultiplier, constant: 1)
        ])
        constraints.append(contentsOf: [
            selectedTabIndicatorTemplate.topAnchor.constraint(equalTo: bannerTemplate.bottomAnchor, constant: 40),
            selectedTabIndicatorTemplate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DRUIKit.Spacing.large.value),
            selectedTabIndicatorTemplate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        constraints.append(contentsOf: [
            menuSectionTemplate.topAnchor.constraint(equalTo: selectedTabIndicatorTemplate.bottomAnchor, constant: 40),
            menuSectionTemplate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DRUIKit.Spacing.large.value),
            menuSectionTemplate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DRUIKit.Spacing.large.value),
            menuSectionTemplate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 40)
        ])
        constraints.forEach { $0.priority = .defaultHigh }
        NSLayoutConstraint.activate(constraints)
    }
    
    private func createView(width: CGFloat? = nil, height: CGFloat? = nil, cornerRadius: CGFloat? = nil) -> UIView {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        if let width {
            let constraint = view.widthAnchor.constraint(equalToConstant: width)
            constraint.priority = .defaultHigh
            view.addConstraint(constraint)
        }
        
        if let height {
            let constraint = view.heightAnchor.constraint(equalToConstant: height)
            constraint.priority = .defaultHigh
            view.addConstraint(constraint)
        }
        
        if let cornerRadius {
            view.roundCorners(by: cornerRadius)
        }
        
        return view
    }
}
