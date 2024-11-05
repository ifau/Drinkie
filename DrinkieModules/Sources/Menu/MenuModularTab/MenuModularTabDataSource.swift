import UIKit

extension MenuModularTabView {
    
    typealias CollectionViewDataSourceType = UICollectionViewDiffableDataSource<Section, SectionData>
    typealias CollectionViewDataSourceSnapshotType = NSDiffableDataSourceSnapshot<Section, SectionData>
    
    enum Section: Hashable {
        case banner(Banner, uniqueHash: Int)
        case productListBlock(ProductListBlock, title: String?, uniqueHash: Int)
        case promotionListBlock(PromotionListBlock, title: String?, uniqueHash: Int)
    }
    
    enum SectionData: Hashable {
        case banner(Banner, uniqueHash: Int)
        case productLink(ProductLink, uniqueHash: Int)
        case promotionLink(PromotionLink, uniqueHash: Int)
    }
    
    func buildDataSource(collectionView: UICollectionView) -> CollectionViewDataSourceType {
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
        collectionView.register(DefaultPromotionCell.self, forCellWithReuseIdentifier: DefaultPromotionCell.reuseIdentifier)
        collectionView.register(DefaultProductCell.self, forCellWithReuseIdentifier: DefaultProductCell.reuseIdentifier)
        collectionView.register(LargeVideoProductCell.self, forCellWithReuseIdentifier: LargeVideoProductCell.reuseIdentifier)
        collectionView.register(LongHeightProductCell.self, forCellWithReuseIdentifier: LongHeightProductCell.reuseIdentifier)
        collectionView.register(ProductBannerCell.self, forCellWithReuseIdentifier: ProductBannerCell.reuseIdentifier)
        collectionView.register(PromotionBannerCell.self, forCellWithReuseIdentifier: PromotionBannerCell.reuseIdentifier)
        
        collectionView.register(BackgroundVideoReusableView.self, forSupplementaryViewOfKind: BackgroundVideoReusableView.kind, withReuseIdentifier: BackgroundVideoReusableView.reuseIdentifier)
        collectionView.register(SectionHeaderReusableView.self, forSupplementaryViewOfKind: SectionHeaderReusableView.kind, withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier)
        
        let datasource = CollectionViewDataSourceType(collectionView: collectionView) { [weak self] (collectionView, indexPath, data) in
            
            switch data {
            case .banner(let banner, _):
                if let productBanner = banner.productBanner {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductBannerCell.reuseIdentifier, for: indexPath) as? ProductBannerCell
                    cell?.configure(productBanner: productBanner, attributesProvider: self?.attributesProvider)
                    return cell
                }
                if let promotionBanner = banner.promotionBanner {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PromotionBannerCell.reuseIdentifier, for: indexPath) as? PromotionBannerCell
                    cell?.configure(promotionBanner: promotionBanner, attributesProvider: self?.attributesProvider)
                    return cell
                }
                
            case .productLink(let productLink, _):
                if case .productListBlock(let block,_,_) = self?.lastDataSourceSnapshot?.sectionIdentifier(containingItem: data) {
                    switch block.style {
                    case .some(.longHeightCells):
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LongHeightProductCell.reuseIdentifier, for: indexPath) as? LongHeightProductCell
                        cell?.configure(productLink: productLink, attributesProvider: self?.attributesProvider)
                        return cell
                    case .some(.largeVideoCells):
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LargeVideoProductCell.reuseIdentifier, for: indexPath) as? LargeVideoProductCell
                        cell?.configure(productLink: productLink, attributesProvider: self?.attributesProvider)
                        return cell
                    case .none:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DefaultProductCell.reuseIdentifier, for: indexPath) as? DefaultProductCell
                        cell?.configure(productLink: productLink, attributesProvider: self?.attributesProvider)
                        return cell
                    }
                }
                
            case .promotionLink(let promotionLink,_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DefaultPromotionCell.reuseIdentifier, for: indexPath) as? DefaultPromotionCell
                cell?.configure(promotionLink: promotionLink, attributesProvider: self?.attributesProvider)
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
            return cell
        }
        
        datasource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            
            guard let section = self?.lastDataSourceSnapshot?.sectionIdentifiers[indexPath.section] else { return nil }
            
            switch section {
            case .banner(let banner, _):
                let backgroundView = collectionView.dequeueReusableSupplementaryView(ofKind: BackgroundVideoReusableView.kind, withReuseIdentifier: BackgroundVideoReusableView.reuseIdentifier, for: indexPath) as? BackgroundVideoReusableView
                backgroundView?.configure(with: banner, attributesProvider: self?.attributesProvider)
                return backgroundView
                
            case .productListBlock(_, let title, _):
                guard let title = title else { return nil }
                let titleView = collectionView.dequeueReusableSupplementaryView(ofKind: SectionHeaderReusableView.kind, withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier, for: indexPath) as? SectionHeaderReusableView
                titleView?.configure(with: title)
                return titleView
                
            case .promotionListBlock(_,_,_):
                return nil
            }
        }
        
        return datasource
    }
}

