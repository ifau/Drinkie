import UIKit
import DRUIKit

final class ProductDetailsCollectionViewLayout: UICollectionViewLayout {
    
    var configuration: ProductDetailsCollectionViewLayout.Configuration = .init()
    var attribues: [ProductDetailsCellAttributes] = []
    var customizationExpanded: Bool = false
    
    var hasCustomizationSection: Bool {
        guard let collectionView else { return false }
        return collectionView.numberOfSections > 2
    }
    
    var pageHeight: CGFloat {
        guard let collectionView else { return .zero }
        let baseHeight = collectionView.frame.height * configuration.actionHeaderTopPaddingRatio + configuration.actionHeaderHeight
        let heightWithCustomization = baseHeight + max(0, configuration.customizationCellEstimatedHeight.collapsed - configuration.actionHeaderHeight)
        
        // round down because scrollRectToVisible not always works with fraction numbers, e.g. 536.1
        return (hasCustomizationSection ? heightWithCustomization : baseHeight).rounded(.down)
    }
    
    override class var layoutAttributesClass: AnyClass {
        ProductDetailsCellAttributes.self
    }
    
    override func prepare() {
        super.prepare()
        
        attribues.removeAll(keepingCapacity: true)
        attribues = calculateInitialAttribues()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView else { return .zero }
        
        let cells = attribues
            .map { $0.copy() as! ProductDetailsCellAttributes }
            .filter { $0.representedElementCategory == .cell }
        
        let supplementaryViews = attribues
            .map { $0.copy() as! ProductDetailsCellAttributes }
            .filter { $0.representedElementCategory == .supplementaryView }
        
        updateAttributes(cells: cells)
        updateAttributes(supplementaryViews: supplementaryViews)
        
        guard let maxAttribue = (cells + supplementaryViews).max(by: { $0.frame.maxY < $1.frame.maxY }) else { return .zero }
        
        let height = max(maxAttribue.frame.maxY, collectionView.frame.height * 2)
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let cells = attribues.filter { $0.representedElementCategory == .cell }
        let supplementaryViews = attribues.filter { $0.representedElementCategory == .supplementaryView }
        
        updateAttributes(cells: cells)
        updateAttributes(supplementaryViews: supplementaryViews)
        
        return (cells + supplementaryViews).filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let cells = attribues.filter { $0.representedElementCategory == .cell && $0.indexPath == indexPath }
        updateAttributes(cells: cells)
        return cells.first
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let supplementaryViews = attribues.filter { $0.representedElementKind == elementKind && $0.indexPath == indexPath }
        updateAttributes(supplementaryViews: supplementaryViews)
        return supplementaryViews.first
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        // velocity.y > 0 scroll down
        // velocity.y < 0 scroll up
        
        guard pageHeight > 0 else { return proposedContentOffset }
        guard let contentOffset = collectionView?.contentOffset else { return proposedContentOffset }
        
        let currentPage = contentOffset.y / pageHeight
        
        let nextPage = velocity.y <= 0 ? (currentPage - 1) : (currentPage + 1)
        
        return CGPoint(x: 0, y: Int(pageHeight) * Int(nextPage))
    }
}

final class ProductDetailsCellAttributes: UICollectionViewLayoutAttributes {
    
    var transitionProgress: CGFloat = 0
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ProductDetailsCellAttributes else { return false }
        guard transitionProgress == object.transitionProgress else { return false }
        return super.isEqual(object)
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        guard let copy = super.copy(with: zone) as? ProductDetailsCellAttributes else { fatalError() }
        copy.transitionProgress = transitionProgress
        return copy
    }
}
