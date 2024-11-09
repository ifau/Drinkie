import UIKit

final class CompositionGroupsCollectionViewLayout: UICollectionViewFlowLayout {
    
    var transitionProgress: CGFloat = 0.0 {
        didSet { invalidateLayout() }
    }
    
    var addInsetsForCenterContent: Bool = false
    
    init(itemSize: CGSize) {
        super.init()
        self.scrollDirection = .horizontal
        self.minimumInteritemSpacing = 0.0
        self.minimumLineSpacing = 8.0
        self.itemSize = itemSize
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override class var layoutAttributesClass: AnyClass {
        CompositionGroupsCellAttributes.self
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        
        let horizontalInsets = addInsetsForCenterContent ? max(0, (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2) : 0.0
        sectionInset = UIEdgeInsets(top: 0.0, left: horizontalInsets, bottom: 0.0, right: horizontalInsets)
        super.prepare()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        
        return attributes.map { attribute in
            applyTransform(to: attribute, in: visibleRect, with: collectionView)
            return attribute
        }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }
        guard let attribute = super.layoutAttributesForItem(at: indexPath) else { return nil }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        applyTransform(to: attribute, in: visibleRect, with: collectionView)
        
        return attribute
    }

    private func applyTransform(to attribute: UICollectionViewLayoutAttributes, in visibleRect: CGRect, with collectionView: UICollectionView) {
        guard let attribute = attribute as? CompositionGroupsCellAttributes else { return }
        
        let distance = visibleRect.midX - attribute.center.x
        let distanceRatioRelaitedToItemWidth = distance / itemSize.width
        var offset = 0.0
        
        if distance.magnitude > itemSize.width {
            offset = 16.0 * transitionProgress
        } else {
            offset = 16.0 * transitionProgress * (distance.magnitude / (itemSize.width))
        }
        if distance < 0 { offset *= -1 }
        
        attribute.transform = CGAffineTransform(translationX: -offset, y: 0)
        attribute.transitionProgress = self.transitionProgress
        attribute.distanceFromCenter = distanceRatioRelaitedToItemWidth
    }

    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }
        guard transitionProgress == 1.0 else { return proposedContentOffset }
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}

final class CompositionGroupsCellAttributes: UICollectionViewLayoutAttributes {
    
    var transitionProgress: CGFloat = 0
    var distanceFromCenter: CGFloat = 0
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? CompositionGroupsCellAttributes else { return false }
        guard transitionProgress == object.transitionProgress, distanceFromCenter == object.distanceFromCenter else { return false }
        return super.isEqual(object)
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        guard let copy = super.copy(with: zone) as? CompositionGroupsCellAttributes else { fatalError() }
        copy.transitionProgress = transitionProgress
        copy.distanceFromCenter = distanceFromCenter
        return copy
    }
}
