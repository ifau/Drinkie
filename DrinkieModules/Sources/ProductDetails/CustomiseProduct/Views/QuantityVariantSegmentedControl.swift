import UIKit
import DRUIKit

final class QuantityVariantSegmentedControl: UIControl {
    
    struct QuantityDescription {
        let id: String
        let title: String
    }
    
    private let verticalPadding: CGFloat = DRUIKit.Spacing.small.value + 2.0
    private let horizontalPadding: CGFloat = DRUIKit.Spacing.medium.value
    
    private var allOptions: [QuantityDescription] = []
    private(set) var selectedOption: QuantityDescription?
    var onSelectedOptionChanged: ((QuantityDescription?) -> Void)?
    
    private lazy var optionsStackView: UIStackView = {
        let view = UIStackView()
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .center
        view.spacing = DRUIKit.Spacing.small.value
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        addSubview(optionsStackView)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateOptionsStackFrame()
    }
    
    private func updateOptionsStackFrame() {
        var elementWidth: CGFloat = 0
        var elementHeight: CGFloat = 0
        optionsStackView
            .arrangedSubviews
            .compactMap { $0.subviews.first as? UILabel }
            .forEach { label in
                elementWidth = max(elementWidth, label.intrinsicContentSize.width)
                elementHeight = max(elementHeight, label.intrinsicContentSize.height)
            }
        
        let totalWidth = elementWidth * CGFloat(allOptions.count)
        + optionsStackView.spacing * max(0, CGFloat(allOptions.count - 1))
        + horizontalPadding * 2 * CGFloat(allOptions.count)
        
        let totalHeight = elementHeight + verticalPadding * 2
        
        optionsStackView.frame.size = CGSize(width: totalWidth, height: totalHeight)
        optionsStackView.frame.origin = CGPoint(x: (bounds.width - totalWidth) / 2, y: (bounds.height - totalHeight) / 2)
        
        optionsStackView.arrangedSubviews.forEach { $0.roundCorners(by: totalHeight / 2.0) }
    }
    
    private func updateSelectedOptionView() {
        
        guard let selectedOption, let selectedIndex = allOptions.firstIndex(where: { $0.id == selectedOption.id }) else { return }
        
        // TODO: - create special gray color in uikit?
        let notSelectedBackgroundColor = UIColor(light: .init(red: 230.0/255.0, green: 235.0/255.0, blue: 238.0/255.0, alpha: 1.0), dark: .clear)
        let notSelectedTextColor = UIColor(red: 161.0/255.0, green: 171.0/255.0, blue: 179.0/255.0, alpha: 1.0)
        
        optionsStackView
            .arrangedSubviews
            .enumerated()
            .forEach { index, view in
                guard let label = view.subviews.first as? UILabel else { return }
                view.backgroundColor = index == selectedIndex ? AppColor.brandPrimary.value : notSelectedBackgroundColor
                label.textColor = index == selectedIndex ? .white : notSelectedTextColor
                label.font = AppFont.relative(.regular, size: (index == selectedIndex ? 16 : 14), relativeTo: .body)
            }
        
        setNeedsLayout()
    }
    
    func setOptions(_ options: [QuantityDescription], selected: QuantityDescription) {
        self.allOptions = options
        self.selectedOption = selected
        
        optionsStackView.arrangedSubviews.forEach {
            optionsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        allOptions.forEach { option in
            let label = UILabel()
            label.text = option.title
            label.textAlignment = .center
            label.textColor = AppColor.textPrimary.value
            label.font = AppFont.relative(.regular, size: 16, relativeTo: .body)
            label.isUserInteractionEnabled = false
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let backgroundView = UIView()
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.isUserInteractionEnabled = true
            backgroundView.addSubview(label)
            
            optionsStackView.addArrangedSubview(backgroundView)
            [
                label.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: verticalPadding),
                label.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: horizontalPadding),
                label.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -horizontalPadding),
                label.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -verticalPadding)
            ].forEach {
                $0.priority = .defaultHigh
                $0.isActive = true
            }
        }
        
        updateSelectedOptionView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard touches.count == 1, let touch = touches.first else { return }
        let touchLocation = touch.location(in: self.optionsStackView)
        
        guard let touchedView = optionsStackView.hitTest(touchLocation, with: event) else { return }
        guard let index = optionsStackView.arrangedSubviews.firstIndex(of: touchedView), index < allOptions.count else { return }
        
        let selected = allOptions[index]
        
        guard selected.id != selectedOption?.id else { return }
        selectedOption = selected
            
        UIView.animate(withDuration: 0.1) {
            self.updateSelectedOptionView()
        } completion: { _ in
            self.sendActions(for: .valueChanged)
            self.onSelectedOptionChanged?(selected)
        }
    }
}
