import UIKit
import DRUIKit

final class CompositionGroupIconView: UIView {
    
    var ingredients: [MutableIngredient] = [] {
        didSet { rebuildGridSubviews() }
    }
    
    private var gridSubviews: [[UIView]] = []
    private var tasks: [Int: Task<Void, Never>] = [:]
    
    private func rebuildGridSubviews() {
        switch ingredients.count {
        case 0:
            gridSubviews = [
                [AddIngredientIconView()]
            ]
        case 1:
            gridSubviews = [
                [imageView(ingredientIndex: 0)]
            ]
        case 2:
            gridSubviews = [
                [imageView(ingredientIndex: 0), imageView(ingredientIndex: 1)]
            ]
        case 3:
            gridSubviews = [
                [imageView(ingredientIndex: 0), imageView(ingredientIndex: 1)],
                [imageView(ingredientIndex: 2)]
            ]
        case 4:
            gridSubviews = [
                [imageView(ingredientIndex: 0), imageView(ingredientIndex: 1)],
                [imageView(ingredientIndex: 2), imageView(ingredientIndex: 3)]
            ]
        default:
            gridSubviews = [
                [imageView(ingredientIndex: 0), moreIconSubview(count: ingredients.count - 3)],
                [imageView(ingredientIndex: 1), imageView(ingredientIndex: 2)]
            ]
        }
        
        subviews.forEach { $0.removeFromSuperview() }
        gridSubviews.flatMap { $0 }.forEach { self.addSubview($0) }
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let numberOfRows = gridSubviews.count
        let rowHeight = (bounds.height / CGFloat(numberOfRows))
        
        for row in 0..<numberOfRows {
            let numberOfColumns = gridSubviews[row].count
            let columnWidth = (bounds.width / CGFloat(numberOfColumns))
            
            let originY = 0.0 + rowHeight * CGFloat(row)
            for column in 0..<numberOfColumns {
                let originX = 0.0 + columnWidth * CGFloat(column)
                let subview = gridSubviews[row][column]
                
                subview.frame = CGRect(x: originX, y: originY, width: columnWidth, height: rowHeight)
                if !subview.isKind(of: UIImageView.self) { // TODO: change
                    subview.roundCorners(by: rowHeight / 2.0)
                }
            }
        }
    }
    
    private func moreIconSubview(count: Int) -> UIView {
        // TODO: fix accessebility attributes
        let view = UIView()
        let iconLabel = UILabel()
        iconLabel.font = AppFont.fixed(.regular, size: 16)
        iconLabel.textColor = UIColor.darkGray// AppColor.textSecondary.value
        iconLabel.text = "+\(count)"
        iconLabel.textAlignment = .center
        iconLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(iconLabel)
        
        view.backgroundColor = .white
        return view
    }
    
    private func imageView(ingredientIndex: Int) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        if let task = tasks[ingredientIndex] {
            task.cancel()
        }
        
        tasks[ingredientIndex] = Task {
            defer { tasks[ingredientIndex] = nil }
            guard ingredients.count > ingredientIndex else { return }
            
            let ingredient = ingredients[ingredientIndex]
            let image = try? await ingredient.loadImage(CGSize(width: 200, height: 200))
            guard !Task.isCancelled else { return }
            imageView.image = image
        }
        
        return imageView
    }
}
