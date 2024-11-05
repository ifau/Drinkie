import UIKit

extension MenuModularTabView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionViewOffsetChanged?(scrollView.contentOffset)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        true
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? LargeVideoProductCell {
            cell.resumeVideoPlayback()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? LargeVideoProductCell {
            cell.pauseVideoPlayback()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let videoBackground = view as? BackgroundVideoReusableView {
            videoBackground.resumeVideoPlayback()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let videoBackground = view as? BackgroundVideoReusableView {
            videoBackground.pauseVideoPlayback()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = collectionViewDataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .banner(let banner, _):
            if let productLink = banner.productBanner?.productLink {
                onEvent?(.productLinkTap(productLink))
            }
            if let promotionLink = banner.promotionBanner?.promotionLink {
                onEvent?(.promotionLinkTap(promotionLink))
            }
            
        case .productLink(let productLink, _):
            onEvent?(.productLinkTap(productLink))
        case .promotionLink(let promotionLink, _):
            onEvent?(.promotionLinkTap(promotionLink))
        }
    }
}
