import UIKit

extension CustomiseProductView {
    typealias CompositionGroupsDataSourceType = UICollectionViewDiffableDataSource<CompositionGroupsSection, CompositionGroupsData>
    typealias CompositionGroupsDataSourceSnapshotType = NSDiffableDataSourceSnapshot<CompositionGroupsSection, CompositionGroupsData>
    
    enum CompositionGroupsSection: Hashable {
        case one
    }
    
    enum CompositionGroupsData: Hashable {
        case group(MutableCompositionGroup)
    }
    
    func buildCompositionGroupDataSource(collectionView: UICollectionView) -> CompositionGroupsDataSourceType {
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
        collectionView.register(CompositionGroupCell.self, forCellWithReuseIdentifier: CompositionGroupCell.reuseIdentifier)
        
        let datasource = CompositionGroupsDataSourceType(collectionView: collectionView) { (collectionView, indexPath, data) in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompositionGroupCell.reuseIdentifier, for: indexPath) as? CompositionGroupCell
            if case let .group(model) = data {
                cell?.configure(with: model)
            }
            return cell
        }
        
        datasource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            return nil
        }
        
        return datasource
    }
}
