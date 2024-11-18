import Foundation

extension ProductDetailsCollectionViewLayout {
    
    func calculateInitialAttribues() -> [ProductDetailsCellAttributes] {
        
        var result: [ProductDetailsCellAttributes] = []
        
        guard let collectionView else { return result }
        guard collectionView.numberOfSections > 0 else { return result }
        
        let backgroundAttribute = ProductDetailsCellAttributes(forSupplementaryViewOfKind: BackgroundVideoReusableView.kind, with: IndexPath(item: 0, section: 0))
        backgroundAttribute.frame = CGRect(origin: .zero, size: CGSize(width: collectionView.frame.width, height: collectionView.frame.height))
        backgroundAttribute.zIndex = ZLevel.backgroundView
        result.append(backgroundAttribute)
        
        let actionHeaderAttribute = ProductDetailsCellAttributes(forSupplementaryViewOfKind: ActionHeaderReusableView.kind, with: IndexPath(item: 0, section: 0))
        actionHeaderAttribute.frame = CGRect(x: 0.0, y: collectionView.frame.height * configuration.actionHeaderTopPaddingRatio, width: collectionView.frame.width, height: configuration.actionHeaderHeight)
        actionHeaderAttribute.zIndex = ZLevel.header
        result.append(actionHeaderAttribute)
        
        var customizationCellAttributes: ProductDetailsCellAttributes?
        if hasCustomizationSection, collectionView.numberOfItems(inSection: 1) == 1 {
            let cellAttributes = ProductDetailsCellAttributes(forCellWith: IndexPath(item: 0, section: 1))
            let spacingAfterActionHeader = 8.0
            
            let customizationCellHeight = min(configuration.customizationCellEstimatedHeight.expanded, collectionView.frame.height - configuration.actionHeaderHeight)
            let customizationCellY = collectionView.frame.height * configuration.actionHeaderTopPaddingRatio + configuration.actionHeaderHeight + spacingAfterActionHeader + configuration.customizationCellEstimatedHeight.collapsed - customizationCellHeight
            
            cellAttributes.frame = CGRect(x: 0, y: customizationCellY, width: collectionView.frame.width, height: customizationCellHeight)
            cellAttributes.zIndex = ZLevel.cell
            
            customizationCellAttributes = cellAttributes
            result.append(cellAttributes)
        }
        
        let infoSectionIndex = hasCustomizationSection ? 2 : 1
        if collectionView.numberOfItems(inSection: infoSectionIndex) == 1 {
            let infoCellAttributes = ProductDetailsCellAttributes(forCellWith: IndexPath(item: 0, section: infoSectionIndex))
            infoCellAttributes.frame = CGRect(x: 0, y: customizationCellAttributes?.frame.maxY ?? actionHeaderAttribute.frame.maxY, width: collectionView.frame.width, height: configuration.infoCellEstimatedHeight)
            infoCellAttributes.zIndex = ZLevel.cell
            result.append(infoCellAttributes)
        }

        return result
    }
    
    func updateAttributes(supplementaryViews: [ProductDetailsCellAttributes]) {
        
        guard pageHeight > 0 else { return }
        guard let contentOffset = collectionView?.contentOffset else { return }
        
        let transitionProgress = min(pageHeight, max(contentOffset.y, 0)) / pageHeight
        
        let backgroundView = supplementaryViews.first(where: { $0.representedElementKind == BackgroundVideoReusableView.kind })
        
        backgroundView?.transitionProgress = transitionProgress
        
        if let actionHeaderView = supplementaryViews.first(where: { $0.representedElementKind == ActionHeaderReusableView.kind }) {

            var y = actionHeaderView.frame.minY + (pageHeight - actionHeaderView.frame.minY) * transitionProgress
            
            if contentOffset.y > pageHeight {
                y = contentOffset.y
            }
            
            if let backgroundView {
                let dy = actionHeaderView.frame.minY - y
                backgroundView.frame = backgroundView.frame.offsetBy(dx: 0, dy: -dy)
            }
            
            actionHeaderView.frame = CGRect(origin: CGPoint(x: 0, y: y), size: actionHeaderView.size)
            actionHeaderView.transitionProgress = transitionProgress
        }
    }
    
    func updateAttributes(cells: [ProductDetailsCellAttributes]) {
        guard pageHeight > 0 else { return }
        guard let contentOffset = collectionView?.contentOffset else { return }
        
        let transitionProgress = min(pageHeight, max(contentOffset.y, 0)) / pageHeight
        
        let customizationCellAttributes: ProductDetailsCellAttributes? = hasCustomizationSection ? cells.first(where: { $0.representedElementCategory == .cell && $0.indexPath == IndexPath(item: 0, section: 1) }) : nil
        
        let infoCellAttributes: ProductDetailsCellAttributes? = cells.first(where: { $0.representedElementCategory == .cell && $0.indexPath == IndexPath(item: 0, section: hasCustomizationSection ? 2 : 1) })
        
        if let customizationCellAttributes {
            if customizationExpanded {
                let y = min(customizationCellAttributes.frame.origin.y + max(contentOffset.y, 0), customizationCellAttributes.frame.origin.y + pageHeight)
                customizationCellAttributes.frame.origin = CGPoint(x: 0, y: y)
                customizationCellAttributes.transitionProgress = transitionProgress
                
                infoCellAttributes?.frame.origin = CGPoint(x: 0, y: customizationCellAttributes.frame.maxY)
            } else {
                let fadeProgress = max(0, 1 - (contentOffset.y / (pageHeight / 1.8)))
                customizationCellAttributes.alpha = fadeProgress
            }
        }
        
        if let infoCellAttributes, !hasCustomizationSection {
            let finaldDY = max(0, pageHeight + configuration.actionHeaderHeight - infoCellAttributes.frame.origin.y)
            infoCellAttributes.frame = infoCellAttributes.frame.offsetBy(dx: 0, dy: finaldDY * transitionProgress)
        }
    }
}
