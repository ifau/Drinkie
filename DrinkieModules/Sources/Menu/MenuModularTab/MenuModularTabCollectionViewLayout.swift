import UIKit
import DRUIKit

final class CustomCompositionalLayout: UICollectionViewCompositionalLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else { return .zero }
        
        let pageHeight = (collectionView.frame.height * MenuView.Constants.tabContentOffsetMultiplier) - 16 // 32 is bar height
        
        if proposedContentOffset.y == 0 {
            return proposedContentOffset
        }
        if proposedContentOffset.y > pageHeight {
            return proposedContentOffset
        }
        
        return CGPoint(x: 0, y: (velocity.y >= 0 ? pageHeight : 0))
    }
}

extension MenuModularTabView {
    
    func buildCollectionViewLayout() -> UICollectionViewLayout {
        
        let layout = CustomCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = self?.lastDataSourceSnapshot?.sectionIdentifiers[sectionIndex] else { return nil }
            
            switch section {
            case .banner(_,_):
                return self?.bannerSectionLayout(layoutEnvironment: layoutEnvironment)
                
            case .productListBlock(let block, let title, _):
                return self?.productListBlockSectionLayout(layoutEnvironment: layoutEnvironment, block: block, title: title)
                
            case .promotionListBlock(let block, let title, _):
                return self?.promotionListBlockSectionLayout(block: block, title: title)
            }
        }
        
        return layout
    }
    
    private func bannerSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(MenuView.Constants.tabContentOffsetMultiplier))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            
            let backgroundViewHeight = environment.container.effectiveContentSize.height
            let scaleFactor = offset.y < 0 ? abs(1.0 - offset.y / 1000.0) : 1.0
            let offsetY = (offset.y) < 0 ? (offset.y) : 0
            let additionalYOffset = ((backgroundViewHeight * scaleFactor) - backgroundViewHeight) / 2
            
            let alpha = offset.y <= 0 ? 1 : (1 - offset.y / (backgroundViewHeight * 0.60))
            
            items
                .filter { $0.representedElementKind == BackgroundVideoReusableView.kind }
                .forEach {
                    $0.transform = CGAffineTransformConcat(
                    CGAffineTransform(translationX: 0, y: offsetY + additionalYOffset),
                    CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                )
            }
            
            items.forEach { $0.alpha = alpha }
        }

        
        let sectionBackgroundSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let sectionBackground = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionBackgroundSize, elementKind: BackgroundVideoReusableView.kind, alignment: .top, absoluteOffset: .init(x: 0, y: 0))
        
        sectionBackground.extendsBoundary = false
        sectionBackground.zIndex = -10
        section.boundarySupplementaryItems = [sectionBackground]
        
        let bottomSpacing = layoutEnvironment.container.contentSize.height * (MenuView.Constants.tabContentOffsetMultiplier - 1) + 16.0 + 64.0
        section.contentInsets = .init(top: 0.0, leading: 0, bottom: bottomSpacing, trailing: 0)
        
        return section
    }
    
    private func productListBlockSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment, block: ProductListBlock, title: String?) -> NSCollectionLayoutSection {
        
        var section: NSCollectionLayoutSection
        
        switch block.style {
        case .some(.longHeightCells):
            // Long height style
            let totalItemsInSection = block.productLinks.count
            let widthForItem: CGFloat = 106.0
            let heightForItem: CGFloat = 186.0
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(widthForItem), heightDimension: .absolute(heightForItem)))
            item.contentInsets = .init(top: 0, leading: 2, bottom: 0, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(CGFloat(totalItemsInSection) * widthForItem), heightDimension: .estimated(heightForItem))
            let sectionGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            section = NSCollectionLayoutSection(group: sectionGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = .init(top: 0, leading: Spacing.large.value, bottom: Spacing.small.value, trailing: Spacing.large.value)
            
        case .some(.largeVideoCells):
            // Large video style
            let totalItemsInSection = block.productLinks.count
            let widthForItem: CGFloat = layoutEnvironment.container.contentSize.width * 0.77
            let heightForItem: CGFloat = layoutEnvironment.container.contentSize.width * 0.94
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(widthForItem), heightDimension: .absolute(heightForItem)))
            item.contentInsets = .init(top: 0, leading: 2, bottom: 0, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(widthForItem * CGFloat(totalItemsInSection)), heightDimension: .estimated(heightForItem))
            let sectionGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            section = NSCollectionLayoutSection(group: sectionGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = .init(top: 0, leading: Spacing.large.value, bottom: Spacing.small.value, trailing: Spacing.large.value)
            
        case .none:
            // Default style layout
            let totalItemsInSection = block.productLinks.count
            let estimatedHeightForItem: CGFloat = 170.0
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .uniformAcrossSiblings(estimate: estimatedHeightForItem)))
            item.contentInsets = .init(top: 0, leading: Spacing.small.value, bottom: 0, trailing: Spacing.small.value)
            
            let twoItemsGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeightForItem))
            let twoItemsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: twoItemsGroupSize, subitems: [item, item])
            
            var sectionSubItems: [NSCollectionLayoutItem] = Array(repeating: twoItemsGroup, count: totalItemsInSection / 2)
            
            if !totalItemsInSection.isMultiple(of: 2) {
                let largeItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(160))
                let largeItem = NSCollectionLayoutItem(layoutSize: largeItemSize)
                largeItem.contentInsets = .init(top: 0, leading: Spacing.small.value, bottom: 0, trailing: Spacing.small.value)
                let largeItemGroup = NSCollectionLayoutGroup.horizontal(layoutSize: largeItemSize, subitems: [largeItem])
                sectionSubItems.insert(largeItemGroup, at: 0)
            }
            
            let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeightForItem * CGFloat(totalItemsInSection)))
            let sectionGroup = NSCollectionLayoutGroup.vertical(layoutSize: sectionSize, subitems: sectionSubItems)
            sectionGroup.interItemSpacing = .fixed(16.0)
            
            section = NSCollectionLayoutSection(group: sectionGroup)
            section.contentInsets = .init(top: 0, leading: Spacing.large.value, bottom: Spacing.small.value, trailing: Spacing.large.value)
            section.interGroupSpacing = Spacing.medium.value
        }
        
        if let _ = title {
            let sectionTitleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(32.0))
            let sectionTitle = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionTitleSize, elementKind: SectionHeaderReusableView.kind, alignment: .top)
            section.boundarySupplementaryItems = [sectionTitle]
        } else {
            section.boundarySupplementaryItems = []
        }
        
        return section
    }
    
    private func promotionListBlockSectionLayout(block: PromotionListBlock, title: String?) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(245))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(245.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: Spacing.medium.value, leading: Spacing.large.value, bottom: Spacing.small.value, trailing: Spacing.large.value)
        return section
    }
}

