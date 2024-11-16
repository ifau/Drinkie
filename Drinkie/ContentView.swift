import SwiftUI
import Combine
import DRAPI
import Menu
import ProductDetails
import SelectStoreUnit

struct ContentView: View {
    
    @EnvironmentObject var session: Session
    @EnvironmentObject var container: DependencyContainer
    
    @State var productDetails: ProductDetailsPresentation?
    @State var selectStoreUnitPresented: Bool = false
    
    var body: some View {
        Group {
            switch session.storeUnit {
            case .none: selectStoreUnitView
            case .some(_): menuView
            }
        }
        .animation(.default, value: session.storeUnit)
    }
    
    private var menuView: some View {
        MenuModule.rootView(dependencies: .init(selectedStoreUnit: selectedStoreUnitPublisher,
                                                fetchMenuView: container.resolve(),
                                                fetchMenu: container.resolve(),
                                                fetchPromotions: container.resolve(),
                                                fetchStops: container.resolve(),
                                                downloadURL: container.resolve(),
                                                navigateToProductDetails: { productDetails = .init(product: $0, relatedProducts: $1) },
                                                navigateToSelectStoreUnit: { selectStoreUnitPresented = true }
                                               )
        )
        .ignoresSafeArea()
        .sheet(item: $productDetails) { destination in
            ProductDetailsModule.rootView(dependencies: .init(product: destination.product,
                                                              relatedProducts: destination.relatedProducts,
                                                              selectedStoreUnit: selectedStoreUnitPublisher,
                                                              downloadURL: container.resolve(),
                                                              fetchStops: container.resolve())
            )
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $selectStoreUnitPresented) {
            selectStoreUnitView
        }
    }
    
    private var selectStoreUnitView: some View {
        SelectStoreUnitModule.rootView(dependencies: .init(selectedUnitId: session.storeUnit?.unit.id,
                                                           downloadURL: container.resolve(),
                                                           fetchChain: container.resolve(),
                                                           selectionHandler: selectStoreUnitHandler,
                                                           dismissPresentation: { selectStoreUnitPresented = false }
                                                          )
                                       )
    }
    
    private func selectStoreUnitHandler(_ unit: DRAPI.Model.GetChain.StoreUnit, _ country: DRAPI.Model.GetChain.Country) {
        session.storeUnit = .init(unit: unit, currency: country.currency)
        selectStoreUnitPresented = false
    }
    
    private var selectedStoreUnitPublisher: AnyPublisher<(unit: DRAPI.Model.GetChain.StoreUnit, currency: DRAPI.Model.GetChain.Currency)?, Never> {
        session.$storeUnit.map { unit in
            guard let unit else { return nil }
            return (unit: unit.unit, currency: unit.currency)
        }
        .eraseToAnyPublisher()
    }
}

extension ContentView {
    struct ProductDetailsPresentation: Identifiable {
        var id: String { product.id }
        let product: DRAPI.Model.GetMenu.Product
        let relatedProducts: [DRAPI.Model.GetMenu.Product]
    }
}

#Preview {
    ContentView()
        .environment(\.dependencyContainer, PreviewContainer())
}
