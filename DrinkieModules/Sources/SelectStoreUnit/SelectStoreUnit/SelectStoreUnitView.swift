import SwiftUI
import DRUIKit

public struct SelectStoreUnitView: View {
    
    @StateObject var viewModel: SelectStoreUnitViewModel
    
    enum DisplayStyle { case map, list }
    @State var selectedDisplayStyle: DisplayStyle = .list
    @State var unitDetails: UnitModel?
    @State var unitDetailsSheetHeight: CGFloat = 300.0
    
    init(viewModel: SelectStoreUnitViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    public var body: some View {
        switch viewModel.state {
        case .notRequested:
            Color.clear.task { viewModel.onEvent(.task) }
            
        case .loading:
            ProgressView()
            
        case .failed(let error):
            GenericErrorView(error: error, tryAgainAction: { viewModel.onEvent(.tryAgainButtonPressed) })
            
        case .loaded(let units, _, let closeEnabled):
            ZStack {
                switch selectedDisplayStyle {
                case .map:
                    MapSelectionView(units: units, selectionHandler: { unitDetails = $0 })
                        .transition(.move(edge: .leading))
                        .ignoresSafeArea(.all)
                case .list:
                    ListSelectionView(units: units, selectionHandler: { unitDetails = $0 })
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.default, value: selectedDisplayStyle)
            .sheet(item: $unitDetails) { unit in
                UnitDetailsView(unit: unit, actionButtonHandler: {
                    // Close sheet and inform model about selection with a little delay to have a smooth animation
                    unitDetails = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                        viewModel.onEvent(.selectedUnit(unit))
                    }
                })
                .presentationCornerRadius(32)
                .fixedSize(horizontal: false, vertical: true)
                .modifier(GetHeightModifier(height: $unitDetailsSheetHeight))
                .presentationDetents([.height(unitDetailsSheetHeight)])
            }
            .overlay(alignment: .top) {
                HStack {
                    Spacer()
                    Button(action: { selectedDisplayStyle = selectedDisplayStyle == .list ? .map : .list }, label: {
                        Image(systemName: selectedDisplayStyle == .list ? "map" : "list.bullet")
                            .foregroundStyle(Color.black)
                            .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
                            .padding(12)
                            .background(Circle().fill(Color(uiColor: .systemGray5)))
                    })
                    if closeEnabled {
                        Button(action: { viewModel.onEvent(.closeButtonPressed) }, label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.black)
                                .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
                                .padding(12)
                                .background(Circle().fill(Color(uiColor: .systemGray5)))
                        })
                    }
                }
                .padding()
            }
        }
    }
}

private struct GetHeightModifier: ViewModifier {
    @Binding var height: CGFloat

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry -> Color in
                DispatchQueue.main.async {
                    height = geometry.size.height
                }
                return Color.clear
            }
        )
    }
}
