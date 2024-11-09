import Foundation
import UIKit
import DRUIKit
import Combine

final public class ProductDetailsViewController: UIViewController {
    
    var viewModel: ProductDetailsViewModel? {
        didSet { subscribeToViewModel() }
    }
    
    private var subscriptions: [AnyCancellable] = []
    private var _view: ProductDetailsView { (self.view as! ProductDetailsView) }
    
    public override func loadView() {
        self.view = ProductDetailsView()
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func subscribeToViewModel() {
        
        viewModel?.customiseProductViewModel.output
            .groupsPublisher
            .map { !$0.isEmpty }
            .removeDuplicates()
            .sink { [weak self] hasCustomisationOptions in
                guard let self else { return }
                let actionHeaderViewModel = viewModel?.actionHeaderViewModel
                let customiseProductViewModel = hasCustomisationOptions ? viewModel?.customiseProductViewModel : nil
                let infoSectionViewModel = viewModel?.infoSectionViewModel
                
                _view.showState(actionHeaderViewModel, customiseProductViewModel, infoSectionViewModel)
            }
            .store(in: &subscriptions)
        
        viewModel?.customiseProductViewModel.input
            .compactMap { event -> CompositionGroup? in
                guard case .didSelectGroup(let group) = event else { return nil }
                return group.group
            }
            .scan((nil, nil)) { ($1, $0.0) }
            .sink { [weak self] currentValue, previousValue in
                guard let self else { return }
                guard _view.collectionViewLayout.customizationExpanded else {
                    _view.changeCustomizationState(expanded: true)
                    return
                }
                _view.changeCustomizationState(expanded: currentValue != previousValue )
            }
            .store(in: &subscriptions)
    }
}

final class ProductDetailsView: UIView {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    lazy var collectionViewDataSource: CollectionViewDataSourceType = {
        buildDataSource(collectionView: collectionView)
    }()
    lazy var collectionViewLayout: ProductDetailsCollectionViewLayout = {
        ProductDetailsCollectionViewLayout()
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = AppColor.backgroundSecondary.value
        addSubview(self.collectionView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = bounds
    }
    
    func showState(_ actionHeaderViewModel: ActionHeaderViewModel?, _ customiseProductViewModel: CustomiseProductViewModel?, _ infoSectionViewModel: InfoSectionViewModel?) {

        var snapshot = CollectionViewDataSourceSnapshotType()
        
        if let actionHeaderViewModel {
            snapshot.appendSections([.main(actionHeaderViewModel)])
        }
        if let customiseProductViewModel {
            snapshot.appendSections([.customisation])
            snapshot.appendItems([.customisation(customiseProductViewModel)], toSection: .customisation)
        }
        if let infoSectionViewModel {
            snapshot.appendSections([.additional])
            snapshot.appendItems([.info(infoSectionViewModel)], toSection: .additional)
        }
        
        collectionViewDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func changeCustomizationState(expanded: Bool) {
        if expanded, !collectionViewLayout.customizationExpanded {
            collectionViewLayout.customizationExpanded = true
            collectionView.scrollRectToVisible(CGRect(origin: .init(x: 0, y: collectionViewLayout.pageHeight), size: collectionView.bounds.size), animated: true)
        }
            
        if !expanded {
            collectionView.scrollRectToVisible(CGRect(origin: .zero, size: collectionView.bounds.size), animated: true)
        }
    }
}

extension ProductDetailsView: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.contentOffset.y == 0 {
            collectionViewLayout.customizationExpanded = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard collectionViewLayout.customizationExpanded else { return }
        
        // minus 8 because content offset not always precise after end decelerating
        // e.g. pageHeight * 2 = 1326 but content offset 1325
        if collectionView.contentOffset.y >= collectionViewLayout.pageHeight * 2 - 8 {
            collectionViewLayout.customizationExpanded = false
            collectionView.scrollRectToVisible(CGRect(origin: .init(x: 0, y: collectionViewLayout.pageHeight), size: collectionView.bounds.size), animated: false)
        }
    }
}
