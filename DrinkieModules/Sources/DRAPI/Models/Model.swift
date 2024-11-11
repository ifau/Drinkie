import Foundation

public enum Model {
    public enum GetMenuView { }
    public enum GetMenu { }
    public enum GetPromotions { }
    public enum GetStops { }
    public enum GetChain { }
}

extension Model.GetMenu.Group: Identifiable {
    public var id: String { code }
}

extension Model.GetMenu.FoodValue {
    
    static public func + (lhs: Model.GetMenu.FoodValue, rhs: Model.GetMenu.FoodValue) -> Model.GetMenu.FoodValue {
        var fats: Double?
        switch (lhs.fats, rhs.fats) {
        case (.none, .none): fats = nil
        case (.some(let lfats), .none): fats = lfats
        case (.none, .some(let rfats)): fats = rfats
        case (.some(let lfats), .some(let rfats)): fats = lfats + rfats
        }
        
        var proteins: Double?
        switch (lhs.proteins, rhs.proteins) {
        case (.none, .none): proteins = nil
        case (.some(let lproteins), .none): proteins = lproteins
        case (.none, .some(let rproteins)): proteins = rproteins
        case (.some(let lproteins), .some(let rproteins)): proteins = lproteins + rproteins
        }
        
        var carbohydrates: Double?
        switch (lhs.carbohydrates, rhs.carbohydrates) {
        case (.none, .none): carbohydrates = nil
        case (.some(let lcarbohydrates), .none): carbohydrates = lcarbohydrates
        case (.none, .some(let rcarbohydrates)): carbohydrates = rcarbohydrates
        case (.some(let lcarbohydrates), .some(let rcarbohydrates)): carbohydrates = lcarbohydrates + rcarbohydrates
        }
        
        var kiloCalories: Double?
        switch (lhs.kiloCalories, rhs.kiloCalories) {
        case (.none, .none): kiloCalories = nil
        case (.some(let lkiloCalories), .none): kiloCalories = lkiloCalories
        case (.none, .some(let rkiloCalories)): kiloCalories = rkiloCalories
        case (.some(let lkiloCalories), .some(let rkiloCalories)): kiloCalories = lkiloCalories + rkiloCalories
        }
        
        var weight: Double?
        switch (lhs.weight, rhs.weight) {
        case (.none, .none): weight = nil
        case (.some(let lweight), .none): weight = lweight
        case (.none, .some(let rweight)): weight = rweight
        case (.some(let lweight), .some(let rweight)): weight = lweight + rweight
        }
        
        return Model.GetMenu.FoodValue(fats: fats, proteins: proteins, carbohydrates: carbohydrates, kiloCalories: kiloCalories, weight: weight)
    }
}
