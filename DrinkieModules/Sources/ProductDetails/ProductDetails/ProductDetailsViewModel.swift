import UIKit
import DRAPI
import Combine

typealias Product = DRAPI.Model.GetMenu.Product
typealias Ingredient = DRAPI.Model.GetMenu.Ingredient
typealias QuantityVariation = DRAPI.Model.GetMenu.QuantityVariation
typealias CompositionGroup = DRAPI.Model.GetMenu.Group
typealias FoodValue = DRAPI.Model.GetMenu.FoodValue

final class ProductDetailsViewModel {

    private(set) var actionHeaderViewModel: ActionHeaderViewModel
    private(set) var customiseProductViewModel: CustomiseProductViewModel
    private(set) var infoSectionViewModel: InfoSectionViewModel
    
    private var subscriptions: [AnyCancellable] = []
    private let dependencies: ProductDetailsModule.Dependencies
    
    init(dependencies: ProductDetailsModule.Dependencies) {
        self.dependencies = dependencies
        
        self.actionHeaderViewModel = ActionHeaderViewModel(selectedProduct: dependencies.product, allProducts: dependencies.relatedProducts, dependencies: dependencies)
        self.customiseProductViewModel = CustomiseProductViewModel(dependencies: dependencies)
        self.infoSectionViewModel = InfoSectionViewModel()
        
        bindInternalViewModels()
    }
    
    private func bindInternalViewModels() {
        let selectedProductPublisher = actionHeaderViewModel.$selectedProduct
        let selectedIngredientsPublisher = customiseProductViewModel.output.selectedIngredientsPublisher
        
        let totalFoodValuePublisher = Publishers
            .CombineLatest(selectedProductPublisher, selectedIngredientsPublisher)
            .map { product, ingredients -> FoodValue? in
                guard let foodValue = product?.foodValue else { return nil }
                return ingredients.compactMap { $1.foodValue }.reduce(foodValue, +)
            }
        
        let totalPricePublisher = Publishers
            .CombineLatest(selectedProductPublisher, selectedIngredientsPublisher)
            .map { product, ingredients in
                (product?.prices.first?.value ?? 0) + ingredients.reduce(into: 0, { $0 += $1.value.price })
            }
        
        selectedProductPublisher
            .sink { [weak self] in
                self?.customiseProductViewModel.input.send(.didSelectProduct($0))
                self?.infoSectionViewModel.description = $0?.description
            }
            .store(in: &subscriptions)
        
        totalPricePublisher
            .sink { [weak self] in self?.actionHeaderViewModel.totalPrice = $0 }
            .store(in: &subscriptions)
        
        totalFoodValuePublisher
            .sink { [weak self] in self?.infoSectionViewModel.foodValue = $0 }
            .store(in: &subscriptions)
    }
}
