import Foundation
import UIKit
import DRUIKit

final class MenuModularTabViewController: UIViewController {
    
    let id: String
    private let tabData: ModularTab
    private var _view: MenuModularTabView { (self.view as! MenuModularTabView) }
    
    var scrollViewOffset: CGPoint {
        get { _view.collectionView.contentOffset }
        set { _view.collectionView.setContentOffset(newValue, animated: false) }
    }
    
    var scrollOffsetChangedHandler: ((_ offset: CGPoint) -> Void)? {
        didSet { _view.collectionViewOffsetChanged = scrollOffsetChangedHandler }
    }
    
    var onEvent: ((_ event: MenuViewModel.Event) -> Void)? {
        get { _view.onEvent }
        set { _view.onEvent = newValue }
    }
    
    var attributesProvider: MenuViewAttributesProvider? {
        get { _view.attributesProvider }
        set { _view.attributesProvider = newValue }
    }
    
    init(id: String, tabData: ModularTab) {
        self.id = id
        self.tabData = tabData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        self.view = MenuModularTabView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let initialScrollOffset = scrollViewOffset
        
        _view.showData(tabData: tabData, animated: false) {
            DispatchQueue.main.async {
                self.scrollViewOffset = initialScrollOffset
                self._view.resumeVideoPlayback()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _view.pauseVideoPlayback()
    }
}


final class MenuModularTabView: UIView {

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = AppColor.backgroundSecondary.value
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.decelerationRate = UIScrollView.DecelerationRate.init(rawValue: 5)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.contentInset.bottom = Spacing.extraLarge.value
        return collectionView
    }()
    lazy var collectionViewDataSource: CollectionViewDataSourceType = {
        buildDataSource(collectionView: collectionView)
    }()
    private lazy var collectionViewLayout: UICollectionViewLayout = {
        buildCollectionViewLayout()
    }()
    var lastDataSourceSnapshot: CollectionViewDataSourceSnapshotType?
    var collectionViewOffsetChanged: ((_ offset: CGPoint) -> Void)?
    var onEvent: ((_ event: MenuViewModel.Event) -> Void)?
    
    weak var attributesProvider: MenuViewAttributesProvider?
    
    init() {
        super.init(frame: .zero)
        self.addSubview(self.collectionView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = bounds
    }
    
    func showData(tabData: ModularTab, animated: Bool = true, completion: (() -> Void)? = nil) {
        
        var uniqueHashDictionary: [AnyHashable:[Int]] = [:]
        func createUniqueHash(_ data: AnyHashable) -> Int {
            var values = uniqueHashDictionary[data] ?? []
            let newValue = (values.last ?? 0) + 1
            values.append(newValue)
            uniqueHashDictionary[data] = values
            return newValue
        }
        
        var snapshot = CollectionViewDataSourceSnapshotType()
        
        let bannerSection = Section.banner(tabData.banner, uniqueHash: createUniqueHash(tabData.banner))
        let bannerSectionData = SectionData.banner(tabData.banner, uniqueHash: createUniqueHash(tabData.banner))
        snapshot.appendSections([bannerSection])
        snapshot.appendItems([bannerSectionData], toSection: bannerSection)
        
        tabData.sections.enumerated().forEach { sectionIndex, apiSection in
            apiSection.blocks.enumerated().forEach { blockIndex, apiBlock in
                
                if let promotionListBlock = apiBlock.promotionListBlock {
                    let promotionSection = Section.promotionListBlock(promotionListBlock, title: apiSection.title, uniqueHash: createUniqueHash(promotionListBlock))
                    let promotionSectionData = promotionListBlock.promotionLinks.map {
                        SectionData.promotionLink($0, uniqueHash: createUniqueHash($0))
                    }
                    snapshot.appendSections([promotionSection])
                    snapshot.appendItems(promotionSectionData, toSection: promotionSection)
                }
                
                if let productListBlock = apiBlock.productListBlock {
                    let productsSection = Section.productListBlock(productListBlock, title: apiSection.title, uniqueHash: createUniqueHash(productListBlock))
                    let productsSectionData = productListBlock.productLinks.map {
                        SectionData.productLink($0, uniqueHash: createUniqueHash($0))
                    }
                    snapshot.appendSections([productsSection])
                    snapshot.appendItems(productsSectionData, toSection: productsSection)
                }
            }
        }
        
        lastDataSourceSnapshot = snapshot
        collectionViewDataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
    
    func pauseVideoPlayback() {
        collectionView
            .visibleCells
            .compactMap { $0 as? LargeVideoProductCell }
            .forEach { $0.pauseVideoPlayback() }
        
        collectionView
            .visibleSupplementaryViews(ofKind: BackgroundVideoReusableView.kind)
            .compactMap { $0 as? BackgroundVideoReusableView }
            .forEach { $0.pauseVideoPlayback() }
    }
    
    func resumeVideoPlayback() {
        collectionView
            .visibleCells
            .compactMap { $0 as? LargeVideoProductCell }
            .forEach { $0.resumeVideoPlayback() }
        
        collectionView
            .visibleSupplementaryViews(ofKind: BackgroundVideoReusableView.kind)
            .compactMap { $0 as? BackgroundVideoReusableView }
            .forEach { $0.resumeVideoPlayback() }
    }
}
