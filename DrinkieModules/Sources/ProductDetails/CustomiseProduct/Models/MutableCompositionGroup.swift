import Foundation

struct MutableCompositionGroup: Hashable {
    let group: CompositionGroup
    var quantities: [MutableQuantity]
    var ingredients: [MutableIngredient]
    var isSelected: Bool
}
