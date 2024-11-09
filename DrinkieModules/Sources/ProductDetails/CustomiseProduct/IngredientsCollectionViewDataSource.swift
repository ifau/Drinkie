import UIKit

extension CustomiseProductView {
    typealias IngredientsDataSourceType = UICollectionViewDiffableDataSource<IngredientsSection, IngredientsData>
    typealias IngredientsDataSourceSnapshotType = NSDiffableDataSourceSnapshot<IngredientsSection, IngredientsData>
    
    struct IngredientsSection: Hashable {
        let title: String
        let quantities: [MutableQuantity]
    }
    
    enum IngredientsData: Hashable {
        case ingredient(MutableIngredient, Bool)
    }
    
    func buildIngredientsDataSource(collectionView: UICollectionView) -> IngredientsDataSourceType {
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
        collectionView.register(IngredientCell.self, forCellWithReuseIdentifier: IngredientCell.reuseIdentifier)
        
        collectionView.register(IngredientsHeaderReusableView.self, forSupplementaryViewOfKind: IngredientsHeaderReusableView.kind, withReuseIdentifier: IngredientsHeaderReusableView.reuseIdentifier)
        collectionView.register(IngredientsFooterReusableView.self, forSupplementaryViewOfKind: IngredientsFooterReusableView.kind, withReuseIdentifier: IngredientsFooterReusableView.reuseIdentifier)
        
        let datasource = IngredientsDataSourceType(collectionView: collectionView) { (collectionView, indexPath, data) in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientCell.reuseIdentifier, for: indexPath) as? IngredientCell
            if case let .ingredient(model, hasAtLeastOnePaidIngredientInGroup) = data {
                cell?.configure(with: model, showSubtitle: hasAtLeastOnePaidIngredientInGroup)
            }
            return cell
        }
        
        datasource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            guard let section = self?.ingredientsDataSource.snapshot().sectionIdentifiers.first else { return nil }
            switch kind {
            case IngredientsHeaderReusableView.kind:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: IngredientsHeaderReusableView.reuseIdentifier, for: indexPath) as? IngredientsHeaderReusableView
                header?.configure(with: section.title)
                return header
            
            case IngredientsFooterReusableView.kind:
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: IngredientsFooterReusableView.reuseIdentifier, for: indexPath) as? IngredientsFooterReusableView
                footer?.configure(quantities: section.quantities, changeHandler: {
                    guard let quantity = $0 else { return }
                    self?.viewModel?.input.send(.didSelectQuantity(quantity))
                })
                return footer
                
            default: return nil
            }
        }
        
        return datasource
    }
}

class TestFooterView: UICollectionReusableView {
    
}
