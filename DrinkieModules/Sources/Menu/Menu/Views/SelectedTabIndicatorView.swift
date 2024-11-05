import UIKit
import DRUIKit

protocol SelectedTabIndicatorViewDelegate: AnyObject {
    func selectedTabChanged(selectedTabDescription: SelectedTabIndicatorView.TabDescription)
}

final class SelectedTabIndicatorView: UIView {
    
    struct TabDescription: Hashable {
        let id: String
        let title: String
    }
    
    var contentSize: CGSize { collectionView.collectionViewLayout.collectionViewContentSize }
    weak var delegate: SelectedTabIndicatorViewDelegate?
    
    // MARK: Private
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(SelectedTabIndicatorViewCell.self, forCellWithReuseIdentifier: SelectedTabIndicatorViewCell.reuseIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var collectionViewDataSource: UICollectionViewDiffableDataSource<Int, TabDescriptionWithState> = {
        UICollectionViewDiffableDataSource<Int, TabDescriptionWithState>(collectionView: collectionView) { collectionView, indexPath, data in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedTabIndicatorViewCell.reuseIdentifier, for: indexPath) as? SelectedTabIndicatorViewCell
            cell?.configure(with: data)
            return cell
        }
    }()
    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(256.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(256.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Spacing.large.value
        section.contentInsets = .init(top: 0, leading: Spacing.large.value, bottom: 0, trailing: Spacing.large.value)
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        configuration.contentInsetsReference = .none
        return UICollectionViewCompositionalLayout(section: section, configuration: configuration)
    }()
    
    init() {
        super.init(frame: .zero)
        addSubview(self.collectionView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = bounds
    }
    
    func configureState(tabDescriptions: [TabDescription], selectedTab: TabDescription) {
        let stateItems = tabDescriptions.map { TabDescriptionWithState(tabDescription: $0, isSelected: $0 == selectedTab) }
        apply(stateItems: stateItems)
    }
    
    func selectTab(withDescription tabDescription: TabDescription) {
        let modifiedItems = collectionViewDataSource.snapshot().itemIdentifiers(inSection: 0).map { item in
            var mutableItem = item
            mutableItem.isSelected = item.tabDescription == tabDescription
            return mutableItem
        }
        
        apply(stateItems: modifiedItems)
    }
    
    func selectTab(withDescriptionId descriptionId: String) {
        let modifiedItems = collectionViewDataSource.snapshot().itemIdentifiers(inSection: 0).map { item in
            var mutableItem = item
            mutableItem.isSelected = item.tabDescription.id == descriptionId
            return mutableItem
        }
        
        apply(stateItems: modifiedItems)
    }
}

fileprivate extension SelectedTabIndicatorView {
    struct TabDescriptionWithState: Hashable {
        let tabDescription: TabDescription
        var isSelected: Bool
    }
    
    func apply(stateItems: [TabDescriptionWithState]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, TabDescriptionWithState>()
        snapshot.appendSections([0])
        snapshot.appendItems(stateItems, toSection: 0)
        
        collectionViewDataSource.apply(snapshot, animatingDifferences: false) {
            guard let selectedItem = stateItems.first(where: { $0.isSelected }), let indexPath = self.collectionViewDataSource.indexPath(for: selectedItem) else { return }
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension SelectedTabIndicatorView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let selectedItem = collectionViewDataSource.itemIdentifier(for: indexPath), !selectedItem.isSelected else { return }
        
        selectTab(withDescription: selectedItem.tabDescription)
        delegate?.selectedTabChanged(selectedTabDescription: selectedItem.tabDescription)
    }
}

// MARK: - Cell Layout

private class SelectedTabIndicatorViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SelectedTabIndicatorViewCell"
    
    private let selectedColor = AppColor.textPrimary.value
    private let notSelectedColor = AppColor.textPrimary.value.withAlphaComponent(0.3)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.relative(.regular, size: 19, relativeTo: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with state: SelectedTabIndicatorView.TabDescriptionWithState) {
        titleLabel.text = state.tabDescription.title
        titleLabel.textColor = state.isSelected ? selectedColor : notSelectedColor
    }
}
