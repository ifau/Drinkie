import UIKit
import DRUIKit
import Combine

final class CustomiseProductView: UIView {
    
    static let ingredientItemSize = CGSize(width: 104, height: 176)
    static let compositionGroupItemSize = CGSize(width: 78, height: 144)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 16, relativeTo: .body)
        label.textColor = AppColor.textPrimary.value
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var ingredientsContainerView: UIView = {
        let view = UIView()
        view.layer.mask = ingredientsContainerMaskLayer
        return view
    }()
    
    private lazy var ingredientsContainerMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        layer.locations = [0, 0.9, 0.95, 1]
        return layer
    }()
    
    private lazy var ingredientsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: ingredientsLayout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var ingredientsLayout: IngredientsCollectionViewLayout = {
        buildIngredientsLayout()
    }()
    
    lazy var ingredientsDataSource: IngredientsDataSourceType = {
        buildIngredientsDataSource(collectionView: ingredientsCollectionView)
    }()
    
    private lazy var compositionGroupsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionGroupsLayout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        collectionView.clipsToBounds = false
        return collectionView
    }()
    
    private lazy var compositionGroupsDataSource: CompositionGroupsDataSourceType = {
        buildCompositionGroupDataSource(collectionView: compositionGroupsCollectionView)
    }()
    private lazy var compositionGroupsLayout: CompositionGroupsCollectionViewLayout = {
        CompositionGroupsCollectionViewLayout(itemSize: CustomiseProductView.compositionGroupItemSize)
    }()
    
    private lazy var selectionIndicatorView: UIView = {
        let view = SelectionIndicatorView()
        return view
    }()
    
    var transitionProgress: CGFloat = 0.0 {
        didSet {
            compositionGroupsLayout.transitionProgress = transitionProgress
            updateAlpha()
            updateFrames()
            if transitionProgress == 0.0 {
                removeCompositionGroupInsetsWithAnimation()
            }
        }
    }
    var viewModel: CustomiseProductViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(selectionIndicatorView)
        addSubview(ingredientsContainerView)
        addSubview(compositionGroupsCollectionView)
        addSubview(titleLabel)
        ingredientsContainerView.addSubview(ingredientsCollectionView)
        
        setupConstraints()
        ingredientsCollectionView.backgroundColor = AppColor.backgroundSecondary.value
        titleLabel.text = "customize as you like it"
    }
    
    private func setupConstraints() {
        selectionIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        compositionGroupsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        ingredientsContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            selectionIndicatorView.centerXAnchor.constraint(equalTo: compositionGroupsCollectionView.centerXAnchor),
            selectionIndicatorView.centerYAnchor.constraint(equalTo: compositionGroupsCollectionView.centerYAnchor),
            selectionIndicatorView.heightAnchor.constraint(equalToConstant: CustomiseProductView.compositionGroupItemSize.height + Spacing.small.value),
            selectionIndicatorView.widthAnchor.constraint(equalToConstant: CustomiseProductView.compositionGroupItemSize.width + Spacing.small.value),
            
            compositionGroupsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            compositionGroupsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            compositionGroupsCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            compositionGroupsCollectionView.heightAnchor.constraint(equalToConstant: CustomiseProductView.compositionGroupItemSize.height),
            
            ingredientsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            ingredientsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ingredientsContainerView.topAnchor.constraint(equalTo: topAnchor),
            ingredientsContainerView.bottomAnchor.constraint(equalTo: compositionGroupsCollectionView.topAnchor)
        ].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    
    private func updateFrames() {
        ingredientsContainerMaskLayer.frame = ingredientsContainerView.bounds
        ingredientsCollectionView.frame = ingredientsContainerView.bounds.offsetBy(dx: 0, dy: ingredientsContainerView.bounds.height * (1 - transitionProgress))
        
        let titleHeight = titleLabel.intrinsicContentSize.height
        titleLabel.frame = CGRect(x: 0, y: compositionGroupsCollectionView.frame.minY - titleHeight, width: bounds.width, height: titleHeight)
        titleLabel.frame = titleLabel.frame.offsetBy(dx: 0, dy: ingredientsContainerView.bounds.height * -transitionProgress)
        
        selectionIndicatorView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }
    
    private func updateAlpha() {
        titleLabel.alpha = 1 - transitionProgress
        ingredientsCollectionView.alpha = transitionProgress
        selectionIndicatorView.alpha = transitionProgress
        selectionIndicatorView.alpha = transitionProgress
    }
    
    var subscriptions: [AnyCancellable] = []
    
    func bindViewModel() {
        subscriptions = []
        guard let viewModel else { return }
        
        viewModel.output.groupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.showCompositionGroups(value)
            }
            .store(in: &subscriptions)
        
        let selectedGroupChangePublisher = viewModel.output.groupsPublisher
            .compactMap { groups in groups.enumerated().first(where: { $1.isSelected }) }
            .scan((nil, 0, 0)) { ($1.element, $1.offset, $0.1) }
        
        selectedGroupChangePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] group, index, oldIndex in
                guard let group else { return }
                self?.showIngredients(group, index: index, oldIndex: oldIndex)
            }
            .store(in: &subscriptions)        
    }
    
    func showCompositionGroups(_ compositionGroups: [MutableCompositionGroup]) {
        var snapshot = CompositionGroupsDataSourceSnapshotType()
        snapshot.appendSections([.one])
        snapshot.appendItems(compositionGroups.map({ CompositionGroupsData.group($0) }), toSection: .one)
        compositionGroupsDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func showIngredients(_ compositionGroup: MutableCompositionGroup, index: Int, oldIndex: Int) {
        let hasAtLeastOnePaidIngredientInGroup = compositionGroup.ingredients.reduce(into: 0, { $0 += $1.quantity.price }) > 0
        
        let section = IngredientsSection(title: compositionGroup.localizedTitle, quantities: compositionGroup.quantities)
        
        var snapshot = IngredientsDataSourceSnapshotType()
        snapshot.appendSections([section])
        snapshot.appendItems(compositionGroup.ingredients.map({IngredientsData.ingredient($0, hasAtLeastOnePaidIngredientInGroup)}), toSection: section)
        
        ingredientsLayout.appearingDirection = index > oldIndex ? .leftToRight : .rightToLeft
        ingredientsDataSource.apply(snapshot, animatingDifferences: (index != oldIndex && transitionProgress == 1.0))
    }
}

extension CustomiseProductView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == ingredientsCollectionView {
            guard let selectedItem = ingredientsDataSource.itemIdentifier(for: indexPath) else { return }
            guard case .ingredient(let ingredient, _) = selectedItem else { return }
            viewModel?.input.send(.didSelectIngredient(ingredient))
        }
        
        if collectionView == compositionGroupsCollectionView {
            guard let selectedItem = compositionGroupsDataSource.itemIdentifier(for: indexPath) else { return }
            guard case .group(let group) = selectedItem else { return }

            let selectionCompletion = {
                self.scrollToItemCentered(at: indexPath, in: self.compositionGroupsCollectionView, animated: true)
                self.viewModel?.input.send(.didSelectGroup(group))
            }
            guard transitionProgress == 1.0 else {
                addCompositionGroupInsetsWithoutAnimation(completion: selectionCompletion)
                return
            }
            selectionCompletion()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard transitionProgress == 1.0 else { return }
        
        if scrollView == compositionGroupsCollectionView {
            let centerPoint = CGPoint(x: compositionGroupsCollectionView.contentOffset.x + compositionGroupsCollectionView.bounds.width / 2.0, y: compositionGroupsCollectionView.contentOffset.y + compositionGroupsCollectionView.bounds.height / 2.0)
            
            guard let centerIndexPath = compositionGroupsCollectionView.indexPathForItem(at: centerPoint) else { return }
            guard let selectedItem = compositionGroupsDataSource.itemIdentifier(for: centerIndexPath) else { return }
            guard case .group(let group) = selectedItem, !group.isSelected else { return }
            self.viewModel?.input.send(.didSelectGroup(group))
        }
    }
}

// MARK: - Helpers

private extension CustomiseProductView {
    
    func scrollToItemCentered(at indexPath: IndexPath, in collectionView: UICollectionView, animated: Bool) {
        guard let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }

        let targetCenterX = layoutAttributes.center.x
        let offsetX = targetCenterX - collectionView.frame.width / 2

        collectionView.setContentOffset(CGPoint(x: offsetX, y: collectionView.contentOffset.y), animated: animated)
    }
    
    func removeCompositionGroupInsetsWithAnimation() {
        compositionGroupsCollectionView.performBatchUpdates({
            compositionGroupsLayout.addInsetsForCenterContent = false
        }, completion: { _ in })
    }
    
    func addCompositionGroupInsetsWithoutAnimation(completion: (() -> Void)?) {
        
        let visibleIndexPath = compositionGroupsCollectionView.indexPathsForVisibleItems.last ?? IndexPath(item: 0, section: 0)
        let oldAttributes = compositionGroupsCollectionView.layoutAttributesForItem(at: visibleIndexPath)
        
        compositionGroupsLayout.addInsetsForCenterContent = true
        UIView.setAnimationsEnabled(false)
        compositionGroupsCollectionView.performBatchUpdates({
            compositionGroupsLayout.invalidateLayout()
        }, completion: { _ in
            let updatedAttributes = self.compositionGroupsCollectionView.layoutAttributesForItem(at: visibleIndexPath)
            if let oldX = oldAttributes?.frame.origin.x,
               let newX = updatedAttributes?.frame.origin.x {
                var newContentOffset = self.compositionGroupsCollectionView.contentOffset
                newContentOffset.x += newX - oldX
                self.compositionGroupsCollectionView.setContentOffset(newContentOffset, animated: false)
            }
            UIView.setAnimationsEnabled(true)
            completion?()
        })
    }
}
