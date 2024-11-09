import UIKit
import DRUIKit

extension CustomiseProductView {
    
    func buildIngredientsLayout() -> IngredientsCollectionViewLayout {
        
        let layout = IngredientsCollectionViewLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            let section: NSCollectionLayoutSection
            
            var totalNumberOfItems = 0
            var totalNumberOfQuantityVariants = 0
            if let snapshot = self?.ingredientsDataSource.snapshot(), let section = snapshot.sectionIdentifiers.first {
                totalNumberOfItems = snapshot.numberOfItems(inSection: section)
                totalNumberOfQuantityVariants = section.quantities.count
            }
            
            if totalNumberOfItems > 3 {
                
                let horizontalSpacing: CGFloat = DRUIKit.Spacing.small.value
                let verticalSpacing: CGFloat = DRUIKit.Spacing.small.value
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(CustomiseProductView.ingredientItemSize.width), heightDimension: .absolute(CustomiseProductView.ingredientItemSize.height))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: itemSize.widthDimension, heightDimension: .absolute(CustomiseProductView.ingredientItemSize.height * 2 + verticalSpacing))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item, item])
                group.interItemSpacing = .fixed(verticalSpacing)
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = horizontalSpacing
                
                let horizontalContentSize = (CustomiseProductView.ingredientItemSize.width * (CGFloat(totalNumberOfItems) / 2.0) + horizontalSpacing * max(0, CGFloat(totalNumberOfItems) / 2.0 - 1))
                
                let horizontalInsets = max(horizontalSpacing, (layoutEnvironment.container.contentSize.width - horizontalContentSize) / 2.0)
                
                let verticalInsets = max(0, layoutEnvironment.container.contentSize.height - (CustomiseProductView.ingredientItemSize.height * 2 + verticalSpacing)) / 2.0
                
                section.contentInsets = .init(top: verticalInsets, leading: horizontalInsets, bottom: verticalInsets, trailing: horizontalInsets)
                
            } else { // short
                
                let horizontalSpacing: CGFloat = DRUIKit.Spacing.small.value
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(CustomiseProductView.ingredientItemSize.width), heightDimension: .absolute(CustomiseProductView.ingredientItemSize.height))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = itemSize
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = horizontalSpacing
                
                let horizontalContentSize = (CustomiseProductView.ingredientItemSize.width * CGFloat(totalNumberOfItems) + horizontalSpacing * CGFloat(max(0, totalNumberOfItems - 1)))
                
                let horizontalInsets = max(horizontalSpacing, (layoutEnvironment.container.contentSize.width - horizontalContentSize) / 2.0)
                
                let verticalInsets = max(0, layoutEnvironment.container.contentSize.height - CustomiseProductView.ingredientItemSize.height) / 2.0
                
                section.contentInsets = .init(top: verticalInsets, leading: horizontalInsets, bottom: verticalInsets, trailing: horizontalInsets)
            }
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .absolute(layoutEnvironment.container.contentSize.width), heightDimension: .absolute(48.0)), elementKind: IngredientsHeaderReusableView.kind, alignment: .top)
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .absolute(layoutEnvironment.container.contentSize.width), heightDimension: .absolute(48.0)), elementKind: IngredientsFooterReusableView.kind, alignment: .bottom, absoluteOffset: .init(x: 0, y: -16))

            header.extendsBoundary = false
            footer.extendsBoundary = false
            section.boundarySupplementaryItems = totalNumberOfQuantityVariants > 1 ? [header, footer] : [header]
            return section
        }
        
        return layout
    }
    
}

final class IngredientsCollectionViewLayout: UICollectionViewCompositionalLayout {
    
    enum AppearingDirection { case leftToRight, rightToLeft }
    var appearingDirection: AppearingDirection = .leftToRight
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }
        updateAttributes(attributes, final: false)
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }
        updateAttributes(attributes, final: true)
        return attributes
    }
    
    override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath) else { return nil }
        updateAttributes(attributes, final: false)
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath) else { return nil }
        updateAttributes(attributes, final: true)
        return attributes
    }
    
    private func updateAttributes(_ attributes: UICollectionViewLayoutAttributes, final: Bool) {
        
        guard let collectionViewWidth = collectionView?.bounds.width else { return }
        
        var xOffset = collectionViewWidth
        if !final, appearingDirection == .leftToRight {
            xOffset = xOffset * -1.0
        }
        if final, appearingDirection == .rightToLeft {
            xOffset = xOffset * -1.0
        }
        attributes.frame = attributes.frame.offsetBy(dx: xOffset, dy: 0)
        attributes.alpha = 0.0
    }
}
