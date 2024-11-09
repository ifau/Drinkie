import UIKit
import DRUIKit
import SwiftUI

class InfoCell: UICollectionViewCell {
    
    static let reuseIdentifier = "InfoCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(viewModel: InfoSectionViewModel) {
        contentConfiguration = UIHostingConfiguration {
            InfoSectionView(viewModel: viewModel)
        }
        .margins(.all, 0)
    }
}
