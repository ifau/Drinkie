import SwiftUI
import DRUIKit
import DRAPI

class InfoSectionViewModel: ObservableObject {
    @Published var foodValue: FoodValue?
    @Published var description: String?
    
    init(foodValue: FoodValue? = nil, description: String? = nil) {
        self.foodValue = foodValue
        self.description = description
    }
}

extension InfoSectionViewModel: Hashable {
    static func == (lhs: InfoSectionViewModel, rhs: InfoSectionViewModel) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct InfoSectionView: View {
    
    @ObservedObject var viewModel: InfoSectionViewModel
    
    var body: some View {
        VStack(spacing: DRUIKit.Spacing.medium.value) {
            foodValueView
            foodDescriptionView
            Spacer()
        }
        .padding(Spacing.medium.value)
        .background(Color(uiColor: AppColor.backgroundSecondary.value))
    }
    
    var foodValueView: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text("Energy")
                    .font(AppFont.relative(.regular, size: 12, relativeTo: .subheadline))
                Text(localizedCalories)
                    .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
                    .contentTransition(.numericText())
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Protein")
                    .font(AppFont.relative(.regular, size: 12, relativeTo: .subheadline))
                Text(localizedProtein)
                    .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
                    .contentTransition(.numericText())
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Fats")
                    .font(AppFont.relative(.regular, size: 12, relativeTo: .subheadline))
                Text(localizedFats)
                    .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
                    .contentTransition(.numericText())
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Carbs")
                    .font(AppFont.relative(.regular, size: 12, relativeTo: .subheadline))
                Text(localizedCarbs)
                    .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
                    .contentTransition(.numericText())
            }
        }
        .padding(Spacing.large.value)
        .background(Color(uiColor: AppColor.backgoundPrimary.value))
        .clipShape(RoundedRectangle(cornerRadius: DRUIKit.CornerRadius.large.value, style: .continuous))
        .animation(.default, value: viewModel.foodValue)
    }
    
    var foodDescriptionView: some View {
        HStack {
            Text(verbatim: viewModel.description ?? "")
                .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
                .layoutPriority(1)
            Spacer(minLength: 0)
        }
        .padding(Spacing.large.value)
        .background(Color(uiColor: AppColor.backgoundPrimary.value))
        .clipShape(RoundedRectangle(cornerRadius: DRUIKit.CornerRadius.large.value, style: .continuous))
    }
}

private extension InfoSectionView {
    var localizedCalories: String {
        guard let value = viewModel.foodValue?.kiloCalories else { return "-" }
        return value.formatted(.number.precision(.fractionLength(0...1))) + " kcal"
    }
    
    var localizedProtein: String {
        guard let value = viewModel.foodValue?.proteins else { return "-" }
        return value.formatted(.number.precision(.fractionLength(0...1))) + " g"
    }
    
    var localizedFats: String {
        guard let value = viewModel.foodValue?.fats else { return "-" }
        return value.formatted(.number.precision(.fractionLength(0...1))) + " g"
    }
    
    var localizedCarbs: String {
        guard let value = viewModel.foodValue?.carbohydrates else { return "-" }
        return value.formatted(.number.precision(.fractionLength(0...1))) + " g"
    }
}
