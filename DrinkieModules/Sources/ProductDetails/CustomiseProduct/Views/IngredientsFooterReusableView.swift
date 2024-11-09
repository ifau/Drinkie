import UIKit
import DRUIKit

class IngredientsFooterReusableView: UICollectionReusableView {
    
    static let reuseIdentifier = "IngredientsFooterReusableView"
    static let kind = "IngredientsFooterReusableViewKind"
    
    // MARK: Private properties
    
    private lazy var quantitySegmentedControl: QuantityVariantSegmentedControl = {
        let view = QuantityVariantSegmentedControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var quantityChangeHandler: ((MutableQuantity?) -> Void)?
    
    // MARK: Required
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(quantitySegmentedControl)
        NSLayoutConstraint.activate([
            quantitySegmentedControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            quantitySegmentedControl.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            quantitySegmentedControl.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor),
            quantitySegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            quantitySegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(quantities: [MutableQuantity], changeHandler: ((MutableQuantity?) -> Void)?) {
        
        guard let selectedIndex = quantities.firstIndex(where: { $0.isSelected }) else { return }
        
        let options = quantities.map { QuantityVariantSegmentedControl.QuantityDescription(id: "\($0.quantityValue)", title: $0.quantityName) }
        
        quantitySegmentedControl.setOptions(options, selected: options[selectedIndex])
        quantitySegmentedControl.onSelectedOptionChanged = { option in
            changeHandler?(quantities.first(where: { "\($0.quantityValue)" == option?.id }))
        }
    }
}

