import UIKit
import Combine

final public class MenuViewController: UIViewController {
    
    var viewModel: MenuViewModel? {
        didSet { subscribeToViewModel() }
    }
    
    private var viewModelSubscription: AnyCancellable?
    private var _view: MenuView { (self.view as! MenuView) }
    
    override public func loadView() {
        self.view = MenuView()
    }
    
    private func subscribeToViewModel() {
        viewModelSubscription = viewModel?.state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?._view.showState($0)
            })
        
        _view.onEvent = { [weak self] in
            self?.viewModel?.input.send($0)
        }
        _view.attributesProvider = viewModel
    }
}
