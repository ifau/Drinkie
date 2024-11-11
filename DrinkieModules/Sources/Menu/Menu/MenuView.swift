import Foundation
import UIKit
import DRUIKit

final class MenuView: UIView {
    
    enum Constants {
        // how much space should we skip from top (overlapping video banner)
        static let tabContentOffsetMultiplier: CGFloat = 0.65
        
        static let selectedTabIndicatorMinimumHeight: CGFloat = 32.0
        
        static let defaultImageSize = CGSize(width: 366.0, height: 366.0)
    }
    
    // MARK: Internal properties
    
    var onEvent: ((MenuViewModel.Event) -> Void)?
    weak var attributesProvider: MenuViewAttributesProvider?
    
    private var overlayView: UIView?
    private var tabs: [Tab] = []
    private var tabsOffsetCache: [String: CGPoint] = [:]
    
    // MARK: Subviews
    
    private lazy var pageViewController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        controller.delegate = self
        controller.dataSource = self
        return controller
    }()

    private var visibleTabViewController: MenuModularTabViewController? {
        pageViewController.viewControllers?.first as? MenuModularTabViewController
    }
    
    private lazy var selectedTabIndicatorView: SelectedTabIndicatorView = {
        let view = SelectedTabIndicatorView()
        view.delegate = self
        return view
    }()
    
    private var selectedTabIndicatorViewBackground: UIView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        view.alpha = 0.0
        return view
    }()
    
    private lazy var storeUnitView: StoreUnitView = {
        let view = StoreUnitView()
        return view
    }()
    
    // MARK: Required methods
    
    init() {
        super.init(frame: .zero)
        addSubview(pageViewController.view)
        addSubview(selectedTabIndicatorViewBackground)
        addSubview(selectedTabIndicatorView)
        addSubview(storeUnitView)
        
        storeUnitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didReceiveTapOnStoreUnitView)))
        storeUnitView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pageViewController.view.frame = bounds
        overlayView?.frame = bounds
        recalculateSelectedTabIndicatorFrame()
        recalculateStoreUnitFrame()
        
        let selectedTabIndicatorViewBackgroundHeight = max(Constants.selectedTabIndicatorMinimumHeight, selectedTabIndicatorView.contentSize.height) + safeAreaInsets.top + Spacing.small.value
        selectedTabIndicatorViewBackground.frame = CGRect(x: 0, y: 0, width: bounds.width, height: selectedTabIndicatorViewBackgroundHeight)
    }
    
    func showState(_ state: MenuViewModel.State) {
        
        switch state {
        case .notRequested: ()
            
        case .loading:
            overlayView?.removeFromSuperview()
            overlayView = LoadingStateView()
            overlayView?.frame = bounds
            addSubview(overlayView!)
            
        case .failed(let error):
            overlayView?.removeFromSuperview()
            overlayView = FailedStateView(error: error, tryAgainAction: nil)
            overlayView?.frame = bounds
            addSubview(overlayView!)
            
        case .loaded(let menuView):
            self.tabs = menuView.tabs
            self.reloadTabs()
            UIView.animate(withDuration: 0.5,
                           animations: { self.overlayView?.alpha = 0.0 },
                           completion: { _ in self.overlayView?.removeFromSuperview() }
            )
        }
    }
    
    private func reloadTabs() {

        let selectedTabIndicators = tabs.map {
            SelectedTabIndicatorView.TabDescription(id: $0.id, title: $0.title)
        }
        
        if let selectedTabDescription = selectedTabIndicators.first {
            selectedTabIndicatorView.configureState(tabDescriptions: selectedTabIndicators, selectedTab: selectedTabDescription)
        }
        
        if let firstTab = tabs.first {
            let vc = createTabController(tab: firstTab)
            pageViewController.setViewControllers([vc], direction: .forward, animated: false)
        }
    }
    
    private func createTabController(tab: Tab) -> MenuModularTabViewController {
        let viewController = MenuModularTabViewController(id: tab.id, tabData: tab.modularTab)
        viewController.scrollOffsetChangedHandler = { [weak self] offset in
            self?.recalculateStoreUnitFrame()
            self?.recalculateSelectedTabIndicatorFrame()
            self?.tabsOffsetCache[tab.id] = offset
        }
        viewController.onEvent = onEvent
        viewController.attributesProvider = attributesProvider
        return viewController
    }
    
    private func recalculateStoreUnitFrame() {
        let activeTabOffset = visibleTabViewController?.scrollViewOffset ?? .zero
        let defaultOffset = safeAreaInsets.top + Spacing.small.value
        let origin = CGPoint(x: Spacing.medium.value, y: min(defaultOffset - activeTabOffset.y, defaultOffset))
        
        storeUnitView.frame = CGRect(origin: origin, size: storeUnitView.intrinsicContentSize)
    }
    
    private func recalculateSelectedTabIndicatorFrame() {
        
        let activeTabOffset = visibleTabViewController?.scrollViewOffset ?? .zero
        let selectedTabIndicatorViewHeight = max(Constants.selectedTabIndicatorMinimumHeight, selectedTabIndicatorView.contentSize.height)
        var y: CGFloat = (bounds.height * MenuView.Constants.tabContentOffsetMultiplier) - activeTabOffset.y + selectedTabIndicatorViewHeight
        if y < safeAreaInsets.top {
            y = safeAreaInsets.top
            selectedTabIndicatorViewBackground.alpha = 1.0
        } else {
            selectedTabIndicatorViewBackground.alpha = 0.0
        }
        selectedTabIndicatorView.frame = CGRect(x: 0.0, y: y, width: bounds.width, height: selectedTabIndicatorViewHeight)
    }
    
    private func fixScrollOffsets(sourceVC: MenuModularTabViewController, destinationVC: MenuModularTabViewController) {
        
        let selectedTabIndicatorViewHeight = max(Constants.selectedTabIndicatorMinimumHeight, selectedTabIndicatorView.contentSize.height)
        let collapsedStyleOffsetY = bounds.height * MenuView.Constants.tabContentOffsetMultiplier - safeAreaInsets.top
        
        let sourceOffset = tabsOffsetCache[sourceVC.id] ?? .zero
        let destinationOffset = tabsOffsetCache[destinationVC.id] ?? .zero
        destinationVC.scrollViewOffset = destinationOffset
        
        if sourceOffset.y >= collapsedStyleOffsetY, destinationOffset.y < collapsedStyleOffsetY {
            destinationVC.scrollViewOffset = CGPoint(x: 0, y: collapsedStyleOffsetY + selectedTabIndicatorViewHeight)
            return
        }
        
        if sourceOffset.y < collapsedStyleOffsetY, destinationOffset.y >= collapsedStyleOffsetY {
            destinationVC.scrollViewOffset = sourceOffset
            return
        }
    }
}

extension MenuView: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard tabs.count > 1 else { return nil }
        guard let currentVC = viewController as? MenuModularTabViewController else { return nil }
        guard let indexOfCurrentVC = tabs.firstIndex(where: { $0.id == currentVC.id }) else { return nil }
        guard let tabData = (indexOfCurrentVC > 0 ? tabs[indexOfCurrentVC - 1] : tabs.last) else { return nil }
        return createTabController(tab: tabData)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard tabs.count > 1 else { return nil }
        guard let currentVC = viewController as? MenuModularTabViewController else { return nil }
        guard let indexOfCurrentVC = tabs.firstIndex(where: { $0.id == currentVC.id }) else { return nil }
        guard let tabData = (indexOfCurrentVC < tabs.count - 1 ? tabs[indexOfCurrentVC + 1] : tabs.first) else { return nil }
        return createTabController(tab: tabData)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let visibleTabViewController = visibleTabViewController, let destinationVC = pendingViewControllers.first as? MenuModularTabViewController else { return }
        fixScrollOffsets(sourceVC: visibleTabViewController, destinationVC: destinationVC)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleTabViewController {
            UIView.animate(withDuration: 0.2) {
                self.recalculateSelectedTabIndicatorFrame()
            }
            selectedTabIndicatorView.selectTab(withDescriptionId: visibleTabViewController.id)
        }
    }
}

extension MenuView: SelectedTabIndicatorViewDelegate {
    func selectedTabChanged(selectedTabDescription: SelectedTabIndicatorView.TabDescription) {

        guard let visibleTabViewController else { return }
        guard let selectedTab = tabs.first(where: { $0.id == selectedTabDescription.id }) else { return }
        guard let selectedIndex = tabs.firstIndex(where: { $0.id == selectedTab.id }) else { return }
        guard let visibleIndex = tabs.firstIndex(where: { $0.id == visibleTabViewController.id }) else { return }
        
        if selectedIndex != visibleIndex {
            let selectedTabViewController = createTabController(tab: selectedTab)
            let direction: UIPageViewController.NavigationDirection = selectedIndex > visibleIndex ? .forward : .reverse
            fixScrollOffsets(sourceVC: visibleTabViewController, destinationVC: selectedTabViewController)
            
            // collectionview will reload its data and trigger scroll view change multiple times with incorrect values
            let oldHandler = selectedTabViewController.scrollOffsetChangedHandler
            selectedTabViewController.scrollOffsetChangedHandler = nil // ignore incorrect offset to prevent visual glitch
            
            pageViewController.setViewControllers([selectedTabViewController], direction: direction, animated: true) { _ in
                selectedTabViewController.scrollOffsetChangedHandler = oldHandler
            }
        }
    }
}

extension MenuView {
    
    @objc func didReceiveTapOnStoreUnitView() {
        onEvent?(.storeUnitButtonPressed)
    }
}
