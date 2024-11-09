import Foundation
import UIKit

struct MutableIngredient {
    let ingredient: Ingredient
    
    var quantity: QuantityVariation
    var isSelected: Bool
    var isAvailable: Bool
    
    let loadImage: (_ size: CGSize) async throws -> UIImage?
}

extension MutableIngredient: Hashable {
    static func == (lhs: MutableIngredient, rhs: MutableIngredient) -> Bool {
        guard lhs.ingredient == rhs.ingredient else { return false }
        guard lhs.quantity == rhs.quantity else { return false }
        guard lhs.isSelected == rhs.isSelected else { return false }
        guard lhs.isAvailable == rhs.isAvailable else { return false }
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ingredient)
        hasher.combine(quantity)
        hasher.combine(isSelected)
        hasher.combine(isAvailable)
    }
}
