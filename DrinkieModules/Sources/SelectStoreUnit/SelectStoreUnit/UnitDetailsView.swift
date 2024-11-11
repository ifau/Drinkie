import SwiftUI
import DRUIKit

struct UnitDetailsView: View {
    
    let unit: UnitModel
    let actionButtonHandler: (() -> Void)?
    
    @State private var fullScreenPictureViewPresented = false
    @State private var fullScreenPictureSelection: String?
    
    init(unit: UnitModel, actionButtonHandler: (() -> Void)?) {
        self.unit = unit
        self.actionButtonHandler = actionButtonHandler
    }
    
    var body: some View {
        VStack(spacing: Spacing.medium.value) {
            unitPictures
            VStack(spacing: Spacing.small.value) {
                Text(unit.alias)
                    .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                    .font(AppFont.relative(.regular, size: 28, relativeTo: .headline))
                
                Text(unit.address)
                    .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                    .font(AppFont.relative(.regular, size: 16, relativeTo: .subheadline))
            }
            .padding(.horizontal, Spacing.small.value)
            
            Spacer(minLength: 1.0)
            HStack {
                workingHoursButton
                getDirectionsButton
            }
            Group {
                orientationDescription
                selectionButton
            }
            .padding(.horizontal, Spacing.extraLarge.value)
        }
        .padding(.top, Spacing.extraLarge.value)
        .fullScreenCover(isPresented: $fullScreenPictureViewPresented) {
            fullScreenUnitPictures
        }
    }
    
    var unitPictures: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(unit.pictures, id: \.self) { picture in
                    AsyncImageView(load: picture.load)
                        .frame(width: 108, height: 192)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large.value, style: .continuous))
                        .onTapGesture {
                            fullScreenPictureSelection = picture.id
                            fullScreenPictureViewPresented = true
                        }
                }
            }
            .padding(.horizontal, Spacing.extraLarge.value)
        }
    }
    
    var fullScreenUnitPictures: some View {
        VStack(spacing: Spacing.large.value) {
            HStack {
                Spacer()
                Button(action: { fullScreenPictureViewPresented = false } ) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                        .font(Font.system(size: 18, weight: .heavy))
                }
                .padding(.horizontal, Spacing.large.value)
            }
            TabView(selection: $fullScreenPictureSelection) {
                ForEach(unit.pictures) { picture in
                    AsyncImageView(load: picture.load)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium.value, style: .continuous))
                        .padding(.horizontal)
                        .tag(picture.id as String?)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Spacer()
            
            HStack {
                ForEach(unit.pictures) { picture in
                    Circle()
                        .fill(Color(uiColor: fullScreenPictureSelection == picture.id ? AppColor.brandSecondary.value : .gray))
                        .frame(width: 8, height: 8)
                        .onTapGesture { fullScreenPictureSelection = picture.id }
                }
            }
            .animation(.default, value: fullScreenPictureSelection)
        }
        .padding(.vertical, Spacing.large.value)
    }
    
    var workingHoursButton: some View {
        if unit.isOpen {
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(Color(uiColor: AppColor.brandPrimary.value))
                    .font(AppFont.relative(.regular, size: 20, relativeTo: .body))
                
                Text(unit.openDescription)
                    .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                    .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
            }
            .padding(.vertical, Spacing.small.value)
            .padding(.horizontal, Spacing.medium.value)
            .background(Color(uiColor: AppColor.backgroundSecondary.value))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large.value, style: .continuous))
        } else {
            HStack(spacing: 4) {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(Color.white)
                    .font(AppFont.relative(.regular, size: 20, relativeTo: .body))
                
                Text("Closed")
                    .foregroundStyle(Color.white)
                    .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
            }
            .padding(.vertical, Spacing.small.value)
            .padding(.horizontal, Spacing.medium.value)
            .background(Color(uiColor: AppColor.brandPrimary.value))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large.value, style: .continuous))
        }
    }
    
    var getDirectionsButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(Color(uiColor: AppColor.brandPrimary.value))
                .font(AppFont.relative(.regular, size: 20, relativeTo: .body))
            
            Text("Route")
                .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
        }
        .padding(.vertical, Spacing.small.value)
        .padding(.horizontal, Spacing.medium.value)
        .background(Color(uiColor: AppColor.backgroundSecondary.value))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large.value, style: .continuous))
    }
    
    var selectionButton: some View {
        Button(action: { actionButtonHandler?() }, label: {
            Text(unit.isOpen ? "Order here" : "Explore menu")
                .font(AppFont.relative(.regular, size: 20, relativeTo: .body))
                .foregroundStyle(Color(uiColor: unit.isOpen ? UIColor.white : AppColor.brandPrimary.value))
                .frame(maxWidth: .infinity)
                .padding(Spacing.medium.value)
                .background(Color(uiColor: unit.isOpen ? AppColor.brandPrimary.value : AppColor.backgroundSecondary.value))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.extraLarge.value, style: .continuous))
        })
    }
    
    var orientationDescription: some View {
        Text(unit.orientation)
            .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(uiColor: AppColor.backgroundSecondary.value))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium.value, style: .continuous))
    }
}


// TODO: - write better component for image loading
struct AsyncImageView: View {
    
    @State var image: UIImage?
    let load: () async throws -> UIImage?
    
    var body: some View {
        switch image {
        case .none:
            Rectangle()
                .fill(Color(uiColor: AppColor.backgroundSecondary.value))
                .task { image = try? await load() }
            
        case .some(let image):
            Image(uiImage: image)
                .resizable()
        }
    }
}
