import SwiftUI
import DRAPI
import Menu
import ProductDetails
import SelectStoreUnit

struct ContentView: View {
    
    @Environment(\.dependencyContainer) var container
    @State var productDetails: ProductDetailsPresentation?
    @State var selectStoreUnitPresented: Bool = false
    
    var body: some View {
        MenuModule.rootView(dependencies: .init(fetchMenuView: container.resolve(),
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
                                                              downloadURL: container.resolve(),
                                                              fetchStops: container.resolve())
            )
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $selectStoreUnitPresented) {
            SelectStoreUnitModule.rootView(dependencies: .init(selectedUnitId: "",
                                                               downloadURL: container.resolve(),
                                                               fetchChain: container.resolve(),
                                                               dismissPresentation: { selectStoreUnitPresented = false }
                                                              )
            )
        }
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
