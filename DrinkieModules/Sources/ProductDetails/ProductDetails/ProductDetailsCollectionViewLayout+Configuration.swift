import Foundation

extension ProductDetailsCollectionViewLayout {
    
    struct Configuration {
        
        let actionHeaderTopPaddingRatio: CGFloat = 0.6
        let actionHeaderHeight: CGFloat = 80.0
        
        // These values could be changed if cell cannot be fitted in collection view bounds
        // like split view, device with small screen, etc.
        let customizationCellEstimatedHeight: (collapsed: CGFloat, expanded: CGFloat) = (collapsed: 160, expanded: 160+490)
        
        let infoCellEstimatedHeight: CGFloat = 500
        
        let unknownCellHeight: CGFloat = 0.1
    }
    
    enum ZLevel {
        static let header = 2
        static let cell = 1
        static let backgroundView = 0
    }
}
