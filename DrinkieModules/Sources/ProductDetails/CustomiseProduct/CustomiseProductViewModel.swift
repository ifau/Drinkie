import Foundation
import DRAPI
import Combine
import UIKit

extension CustomiseProductViewModel {
    enum InputEvent {
        case didSelectGroup(MutableCompositionGroup)
        case didSelectIngredient(MutableIngredient)
        case didSelectQuantity(MutableQuantity)
        case didSelectProduct(Product?)
        case didReceiveCurrency(DRAPI.Model.GetChain.Currency?)
    }
    
    struct OutputState {
        let groupsPublisher: AnyPublisher<[MutableCompositionGroup], Never>
        let selectedIngredientsPublisher: AnyPublisher<[Ingredient : QuantityVariation], Never>
    }
}

final class CustomiseProductViewModel {
    
    let input = PassthroughSubject<InputEvent, Never>()
    lazy private(set) var output: OutputState = {
        return OutputState(groupsPublisher: groupsSubject.eraseToAnyPublisher(),
                           selectedIngredientsPublisher: selectedIngredientsSubject.eraseToAnyPublisher())
    }()
    
    private var currency: DRAPI.Model.GetChain.Currency? {
        didSet { didReceiveCurrency() }
    }
    
    private var subscriptions: [AnyCancellable] = []
    private let groupsSubject = CurrentValueSubject<[MutableCompositionGroup], Never>([])
    private let selectedIngredientsSubject = CurrentValueSubject<[Ingredient : QuantityVariation], Never>([:])
    private let dependencies: ProductDetailsModule.Dependencies
    
    init(dependencies: ProductDetailsModule.Dependencies) {
        self.dependencies = dependencies
        createInputSubscription()
    }
    
    private func createInputSubscription() {
        input.sink { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .didSelectGroup(let group): didSelectGroup(group)
            case .didSelectIngredient(let ingredient): didSelectIngredient(ingredient)
            case .didSelectQuantity(let quantity): didSelectQuantity(quantity)
            case .didSelectProduct(let product): reset(withGroups: product?.composition?.groups ?? [])
            case .didReceiveCurrency(let currency): self.currency = currency
            }
        }
        .store(in: &subscriptions)
        
        groupsSubject
            .map { groups in groups.flatMap { $0.ingredients.filter { $0.isSelected } } }
            .map { ingredients in
                ingredients.reduce(into: Dictionary<Ingredient, QuantityVariation>()) { $0[$1.ingredient] = $1.quantity }
            }
            .sink { [weak self] in self?.selectedIngredientsSubject.send($0) }
            .store(in: &subscriptions)
    }

    private func reset(withGroups groups: [CompositionGroup]) {
        
        let selectedGroup = groupsSubject.value.first(where: { $0.isSelected })
        let selectedIngredients = selectedIngredientsSubject.value
        
        var updatedGroups = groups.compactMap { group -> MutableCompositionGroup? in
            
            // Create unique quantity variants
            // e.g. Espresso ingredient has 3 groups: "0-0", "Standart-1", "Stronger-2"
            var uniqueQuantites: [MutableQuantity] =  []
            group
                .ingredients
                .flatMap { $0.quantityVariations }
                .map { MutableQuantity(quantityName: $0.name, quantityValue: $0.quantity, isSelected: false) }
                .forEach { quantity in
                    guard !uniqueQuantites.contains(CollectionOfOne(quantity)) else { return }
                    uniqueQuantites.append(quantity)
                }
            
            // Remove zero quantity variant because it is default value if not other quantities are selected
            if uniqueQuantites.count > 1 {
                uniqueQuantites = uniqueQuantites.filter { $0.quantityValue > 0 }
            }
            guard !uniqueQuantites.isEmpty else { return nil }
            
            var selectedQuantity: MutableQuantity
            let selectedIngredientsForGroup = selectedIngredients.filter { group.ingredients.contains(CollectionOfOne($0.key)) }
            
            if let selectedQuantityIndex = uniqueQuantites.firstIndex(where: { quantity in
                selectedIngredientsForGroup.contains { $0.value.quantity == quantity.quantityValue }
            }) {
                uniqueQuantites[selectedQuantityIndex].isSelected = true
                selectedQuantity = uniqueQuantites[selectedQuantityIndex]
            } else {
                uniqueQuantites[0].isSelected = true
                selectedQuantity = uniqueQuantites[0]
            }
            
            let ingredients: [MutableIngredient] = group
                .ingredients
                .compactMap { ingredient in
                    guard let quantityVariant = ingredient.quantityVariations.first(where: { $0.quantity == selectedQuantity.quantityValue }) else { return nil }
                    let isSelected = selectedIngredients.contains(where: { $0.key.id == ingredient.id })
                    let loadImage: (_ size: CGSize) async throws -> UIImage? = { [weak self] size in
                        return try await self?.getImage(ingredient: ingredient, size: size)
                    }
                    return MutableIngredient(ingredient: ingredient,
                                             quantity: quantityVariant,
                                             isSelected: isSelected,
                                             isAvailable: true,
                                             currency: currency?.isoAlpha3,
                                             loadImage: loadImage)
                }
            
            return MutableCompositionGroup(group: group, quantities: uniqueQuantites, ingredients: ingredients, isSelected: group.id == selectedGroup?.group.id)
        }
        
        updatedGroups = updatedGroups.map { buildValidGroupState(group: $0, afterSelectionOf: nil) }
        groupsSubject.send(updatedGroups)
    }
    
    func didSelectGroup(_ group: MutableCompositionGroup) {
        
        let updatedGroups = groupsSubject.value.map { mutableGroup in
            var updatedGroup = mutableGroup
            updatedGroup.isSelected = (mutableGroup == group)
            return updatedGroup
        }
        
        groupsSubject.send(updatedGroups)
    }
    
    func didSelectIngredient(_ selectedIngredient: MutableIngredient) {

        let updatedGroups = groupsSubject.value.map { mutableGroup in
            var updatedGroup = mutableGroup
            
            guard let selectedIndex = updatedGroup.ingredients.firstIndex(where: { $0 == selectedIngredient }) else {
                return mutableGroup
            }
            
            updatedGroup.ingredients[selectedIndex].isSelected.toggle()
            updatedGroup = buildValidGroupState(group: updatedGroup, afterSelectionOf: updatedGroup.ingredients[selectedIndex])

            return updatedGroup
        }
        
        groupsSubject.send(updatedGroups)
    }
    
    func didSelectQuantity(_ selectedQuantity: MutableQuantity) {
        
        let updatedGroups = groupsSubject.value.map { mutableGroup in
            
            guard mutableGroup.isSelected else { return mutableGroup }
            
            var updatedGroup = mutableGroup
            
            updatedGroup.quantities = updatedGroup.quantities.map { quantity in
                var updatedQuantity = quantity
                updatedQuantity.isSelected = (quantity == selectedQuantity)
                return updatedQuantity
            }
            
            updatedGroup.ingredients = updatedGroup.ingredients.compactMap { ingredient in
                guard let quantityVariation = ingredient.ingredient.quantityVariations.first(where: { $0.quantity == selectedQuantity.quantityValue }) else { return nil }
                
                var updatedIngredient = ingredient
                updatedIngredient.quantity = quantityVariation
                return updatedIngredient
            }
            
            return updatedGroup
        }
        
        groupsSubject.send(updatedGroups)
    }
    
    func didReceiveCurrency() {
        let updatedGroups = groupsSubject.value.map { mutableGroup in
            
            var updatedGroup = mutableGroup
            updatedGroup.ingredients = updatedGroup.ingredients.map { ingredient in

                var updatedIngredient = ingredient
                updatedIngredient.currency = currency?.isoAlpha3
                return updatedIngredient
            }
            
            return updatedGroup
        }
        
        groupsSubject.send(updatedGroups)
    }
    
    private func buildValidGroupState(group: MutableCompositionGroup, afterSelectionOf recentlyChangedIngredient: MutableIngredient?) -> MutableCompositionGroup {
        
        var result = group
        
        if case .none = group.group.choiceType {
            result.ingredients = result.ingredients.map { ingredient in
                var updatedIngredient = ingredient
                updatedIngredient.isSelected = false
                return updatedIngredient
            }
            return result
        }
        
        if case .multi = group.group.choiceType {
            let totalQuantity = { (group: MutableCompositionGroup) -> Int in
                group.ingredients.reduce(into: 0) { result, ingredient in
                    result += ingredient.isSelected ? ingredient.quantity.quantity : 0
                }
            }
            
            while totalQuantity(group) > result.group.totalQuantityMax {
                let indexToDeselect = result.ingredients.firstIndex { ingredient in
                    if let recentlyChangedIngredient, ingredient == recentlyChangedIngredient { return false }
                    return ingredient.isSelected
                }
                guard let indexToDeselect else { break }
                result.ingredients[indexToDeselect].isSelected = false
            }
            
            return result
        }
        
        if case .single = group.group.choiceType {
            guard !group.ingredients.isEmpty else { return result }
            var selectedIngredientIndex = group.ingredients.firstIndex(where: { $0.isSelected })
            if let recentlyChangedIngredient {
                selectedIngredientIndex = group.ingredients.firstIndex(of: recentlyChangedIngredient)
            }
            if selectedIngredientIndex == nil {
                selectedIngredientIndex = 0
            }
            
            result.ingredients = result.ingredients.enumerated().map { index, ingredient in
                var updatedIngredient = ingredient
                updatedIngredient.isSelected = index == selectedIngredientIndex
                return updatedIngredient
            }
            return result
        }
        
        return result
    }
    
    private func getImage(ingredient: Ingredient, size: CGSize) async throws -> UIImage? {
        
        var templateURL = ingredient.imageURLTemplate
        templateURL = templateURL.replacingOccurrences(of: "{width}", with: size.width.formatted())
        templateURL = templateURL.replacingOccurrences(of: "{height}", with: size.height.formatted())
        templateURL = templateURL.replacingOccurrences(of: "{ext}", with: "heic")
        
        guard let url = URL(string: templateURL) else {
            throw URLError(URLError.badURL)
        }
        
        let localURL = try await dependencies.downloadURL(url)
        guard let image = UIImage(contentsOfFile: localURL.path) else {
            throw URLError(URLError.badURL)
        }
        return image
    }
}

extension CustomiseProductViewModel: Hashable {
    static func == (lhs: CustomiseProductViewModel, rhs: CustomiseProductViewModel) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

// MARK: - Display Cell Data

extension MutableCompositionGroup: CompositionGroupCellModel {
    var localizedTitle: String {
        let selected = ingredients.filter { $0.isSelected }
        guard selected.count == 1, let ingredient = selected.first?.ingredient else { return group.name }
        return ingredient.name
    }
    
    var localizedPrice: String {
        let currency = ingredients.first?.currency ?? ""
        let groupPrice = ingredients.filter { $0.isSelected }.reduce(into: 0, { $0 += $1.quantity.price })
        return groupPrice > 0 ? "\(currency) \(groupPrice)" : ""
    }
}

extension MutableIngredient: IngredientCellModel {
    
    var localizedTitle: String { ingredient.name }
    var localizedSubtitle: String {
        let currency = self.currency ?? ""
        return quantity.price > 0 ? "+\(currency) \(quantity.price)" : "\(currency) 0"
    }
}
