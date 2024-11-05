import UIKit

final class FailedStateView: UIView {
    
    init(error: Error, tryAgainAction: (() -> Void)?) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
