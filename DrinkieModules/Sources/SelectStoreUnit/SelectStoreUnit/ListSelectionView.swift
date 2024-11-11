import SwiftUI
import DRUIKit

struct ListSelectionView: View {
    
    let unitGroups: [UnitGroup]
    let selectionHandler: ((UnitModel) -> Void)?
    
    init(units: [UnitModel], selectionHandler: ((UnitModel) -> Void)?) {
        
        let cities = units.reduce(into: Dictionary<String, String>()) { $0[$1.unit.cityID] = $1.unit.address.cityName }
        
        self.unitGroups = cities
            .map { cityId, cityName in
                let units = units.filter({ $0.unit.cityID == cityId }).sorted(by: { $0.alias < $1.alias})
                return UnitGroup(groupId: cityId, groupTitle: cityName, units: units)
            }
            .sorted(by: { $0.groupTitle < $1.groupTitle })
        
        self.selectionHandler = selectionHandler
    }
    
    var body: some View {
        ScrollView {
            ForEach(unitGroups, id: \.groupId) { group in
                VStack(alignment: .leading, spacing: Spacing.small.value) {
                    
                    Spacer().frame(height: Spacing.small.value)
                    
                    Text(group.groupTitle)
                        .foregroundStyle(Color(uiColor: AppColor.brandPrimary.value))
                        .font(AppFont.relative(.regular, size: 28, relativeTo: .headline))
                    
                    Spacer().frame(height: Spacing.small.value)
                    
                    ForEach(group.units) { unit in
                        row(unit: unit).onTapGesture {
                            selectionHandler?(unit)
                        }
                    }
                }.padding(.horizontal)
            }
        }
    }

    func row(unit: UnitModel) -> some View {
        VStack(spacing: 0.0) {
            HStack {
                VStack(alignment: .leading, spacing: 4.0) {
                    Text(unit.alias)
                        .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                        .font(AppFont.relative(.regular, size: 20, relativeTo: .body))
                    Text(unit.address)
                        .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                        .font(AppFont.relative(.regular, size: 14, relativeTo: .body))
                    
                    Spacer().frame(height: 1.0)
                    
                    Text(unit.openDescription)
                        .foregroundStyle(unit.isOpen ? Color.gray : Color.red)
                        .font(AppFont.relative(.regular, size: 14, relativeTo: .body))
                    
                    Spacer().frame(height: 1.0)
                }
                Spacer()
                if unit.isSelected {
                    Circle()
                        .fill(Color(uiColor: AppColor.brandPrimary.value))
                        .frame(width: 14, height: 14)
                }
            }
            Divider()
        }
    }
}

extension ListSelectionView {
    
    struct UnitGroup {
        let groupId: String
        let groupTitle: String
        let units: [UnitModel]
    }
}
