import UIKit

extension ProductDetailsView {
    
    typealias CollectionViewDataSourceType = UICollectionViewDiffableDataSource<Section, SectionData>
    typealias CollectionViewDataSourceSnapshotType = NSDiffableDataSourceSnapshot<Section, SectionData>
    
    enum Section: Hashable {
        case main(ActionHeaderViewModel)
        case customisation
        case additional
    }
    
    enum SectionData: Hashable {
        case customisation(CustomiseProductViewModel)
        case info(InfoSectionViewModel)
    }
    
    func buildDataSource(collectionView: UICollectionView) -> CollectionViewDataSourceType {
        
        collectionView.register(CustomiseProductCell.self, forCellWithReuseIdentifier: CustomiseProductCell.reuseIdentifier)
        collectionView.register(InfoCell.self, forCellWithReuseIdentifier: InfoCell.reuseIdentifier)
        
        collectionView.register(BackgroundVideoReusableView.self, forSupplementaryViewOfKind: BackgroundVideoReusableView.kind, withReuseIdentifier: BackgroundVideoReusableView.reuseIdentifier)
        collectionView.register(ActionHeaderReusableView.self, forSupplementaryViewOfKind: ActionHeaderReusableView.kind, withReuseIdentifier: ActionHeaderReusableView.reuseIdentifier)
        
        let datasource = CollectionViewDataSourceType(collectionView: collectionView) { (collectionView, indexPath, data) in
            
            switch data {
            case .customisation(let viewModel):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomiseProductCell.reuseIdentifier, for: indexPath) as? CustomiseProductCell
                cell?.configure(viewModel: viewModel)
                return cell
                
            case .info(let viewModel):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InfoCell.reuseIdentifier, for: indexPath) as? InfoCell
                cell?.configure(viewModel: viewModel)
                return cell
            }
        }
        
        datasource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            guard case .main(let actionHeaderViewModel) = self?.collectionViewDataSource.sectionIdentifier(for: indexPath.section) else { return UICollectionReusableView() }
            
            switch kind {
            case ActionHeaderReusableView.kind:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: ActionHeaderReusableView.kind, withReuseIdentifier: ActionHeaderReusableView.reuseIdentifier, for: indexPath) as? ActionHeaderReusableView
                view?.configure(viewModel: actionHeaderViewModel)
                return view
            
            case BackgroundVideoReusableView.kind:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: BackgroundVideoReusableView.kind, withReuseIdentifier: BackgroundVideoReusableView.reuseIdentifier, for: indexPath) as? BackgroundVideoReusableView
                view?.configure(viewModel: actionHeaderViewModel)
                return view
                
            default: return nil
            }
        }
        
        return datasource
    }
}

