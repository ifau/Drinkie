import SwiftUI

public struct GenericErrorView: View {
    
    let error: Error
    let tryAgainAction: (() -> Void)?
    
    public init(error: Error, tryAgainAction: (() -> Void)?) {
        self.error = error
        self.tryAgainAction = tryAgainAction
    }
    
    public var body: some View {
        VStack(spacing: Spacing.small.value) {
            Text("An error has occured")
                .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                .font(AppFont.relative(.regular, size: 24, relativeTo: .headline))
            
            Text(error.localizedDescription)
                .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                .font(AppFont.relative(.regular, size: 16, relativeTo: .headline))
            
            if tryAgainAction != nil {
                Spacer()
                    .frame(height: Spacing.extraLarge.value)
                
                Button(action: { tryAgainAction?() }, label: {
                    Text("Try again")
                        .font(AppFont.relative(.regular, size: 20, relativeTo: .body))
                        .foregroundStyle(Color(uiColor: AppColor.brandPrimary.value))
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.medium.value)
                        .background(Color(uiColor: AppColor.backgroundSecondary.value))
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.extraLarge.value, style: .continuous))
                })
            }
        }
        .padding(Spacing.large.value)
    }
}

#Preview {
    GenericErrorView(error: URLError(.networkConnectionLost), tryAgainAction: {})
}
