import UIKit
import DRUIKit
import SwiftUI

class ActionHeaderReusableView: UICollectionReusableView {
    
    static let reuseIdentifier = "ActionHeaderReusableView"
    static let kind = "ActionHeaderReusableView"
    
    // MARK: Private properties
    
    private var materialBackground: UIView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        view.alpha = 0.0
        return view
    }()
    
    private var hostingView: UIView?
    private var observableAttributes = ActionHeaderViewAttributes()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(materialBackground)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? ProductDetailsCellAttributes else { return }
        observableAttributes.transitionProgress = attributes.transitionProgress
        
        let blurVisibility = max(0, (attributes.transitionProgress - 0.9)) / 0.1
        materialBackground.alpha = blurVisibility
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        materialBackground.frame = bounds
        hostingView?.frame = bounds
    }
    
    func configure(viewModel: ActionHeaderViewModel) {
        hostingView?.removeFromSuperview()
        hostingView = UIHostingController(rootView: ActionHeaderView(viewModel: viewModel, attributes: observableAttributes)).view
        addSubview(hostingView!)
        hostingView?.frame = bounds
        hostingView?.backgroundColor = .clear
    }
}

class ActionHeaderViewModel: ObservableObject {
    
    @Published var totalPrice: Int
    @Published var selectedProduct: Product?
    @Published var allProducts: [Product]
    
    let dependencies: ProductDetailsModule.Dependencies
    
    init(totalPrice: Int = 0, selectedProduct: Product?, allProducts: [Product], dependencies: ProductDetailsModule.Dependencies) {
        self.totalPrice = totalPrice
        self.selectedProduct = selectedProduct
        self.allProducts = allProducts
        self.dependencies = dependencies
    }
    
    func loadBannerPreviewImage() async throws -> UIImage? {
        guard let selectedProduct else { return nil }
        guard let previewURL = URL(string: selectedProduct.banner.preview.url) else { return nil }
        let localURL = try await dependencies.downloadURL(previewURL)
        
        guard let image = UIImage(contentsOfFile: localURL.path) else { return nil }
        return image
    }
    
    func loadBannerVideo() async throws -> URL? {
        guard let selectedProduct else { return nil }
        guard let videoURL = URL(string: selectedProduct.banner.videos.first?.url ?? "") else { return nil }
        return try await dependencies.downloadURL(videoURL)
    }
}

extension ActionHeaderViewModel: Hashable {
    static func == (lhs: ActionHeaderViewModel, rhs: ActionHeaderViewModel) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

class ActionHeaderViewAttributes: ObservableObject {
    @Published var transitionProgress: CGFloat = 0.0
}

struct ActionHeaderView: View {
    
    @ObservedObject var viewModel: ActionHeaderViewModel
    @ObservedObject var attributes: ActionHeaderViewAttributes
    
    var body: some View {
        HStack(spacing: 0) {
            if viewModel.allProducts.count > 1 {
                sizeSelectorView
            } else {
                sizeView
            }
            Spacer()
            priceLabel
            Spacer().frame(width: DRUIKit.Spacing.medium.value)
            actionButton
        }
        .padding(.horizontal, horizontalSpacing)
    }
    
    var sizeView: some View {
        HStack {
            Text(viewModel.selectedProduct?.sizeName ?? "")
                .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                .font(AppFont.relative(.regular, size: 16, relativeTo: .body))
                .frame(minWidth: 48, minHeight: 48)
                .padding(.horizontal, 24)
        }
        .background(Color(uiColor: AppColor.backgoundPrimary.value))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .circular))
    }
    
    var sizeSelectorView: some View {
        HStack {
            HStack(spacing: 0) {
                ForEach(viewModel.allProducts, id: \.self.id) { product in
                    Button(action: { viewModel.selectedProduct = product }, label: {
                        Text(product.sizeLabel.rawValue)
                            .foregroundStyle(Color(uiColor: AppColor.textPrimary.value))
                            .font(AppFont.relative(.regular, size: 13, relativeTo: .body))
                            .frame(minWidth: 48, minHeight: 48)
                    })
                }
            }
            .background(Color(uiColor: .quaternarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .circular))
            .padding(4)
        }
        .overlay(alignment: .leading) {
            Circle()
                .fill(Color(uiColor: AppColor.brandPrimary.value))
                .overlay {
                    VStack(spacing: 0) {
                        Text(viewModel.selectedProduct?.sizeLabel.rawValue ?? "")
                            .foregroundStyle(.white)
                            .font(AppFont.fixed(.regular, size: 20))
                        Text(viewModel.selectedProduct?.sizeName ?? "")
                            .foregroundStyle(.white)
                            .font(AppFont.fixed(.regular, size: 8))
                            .offset(y: -2)
                }
            }
            .offset(x: selectedSizeCircleOffset, y: 0)
            .animation(.interpolatingSpring(duration: 0.2), value: selectedSizeCircleOffset)
        }
    }
    
    var priceLabel: some View {
        Text("RUB \(viewModel.totalPrice)")
            .font(AppFont.relative(.regular, size: 20, relativeTo: .headline))
    }
    
    var actionButton: some View {
        Button(action: {}, label: {
            Text("+")
                .foregroundStyle(.white)
                .baselineOffset(2)
                .font(AppFont.fixed(.regular, size: 34))
                .frame(width: 56, height: 56)
        })
        .background(Color(uiColor: AppColor.brandPrimary.value))
        .clipShape(Circle())
    }
    
    private var selectedSizeCircleOffset: CGFloat {
        guard let selectedProduct = viewModel.selectedProduct else { return 0.0 }
        guard let index = viewModel.allProducts.firstIndex(where: { $0.id == selectedProduct.id } ) else { return 0.0 }
        return index > 0 ? CGFloat(index) * 48.0 + 2.0 : 0
    }
    
    private var horizontalSpacing: CGFloat { DRUIKit.Spacing.large.value - (DRUIKit.Spacing.small.value * attributes.transitionProgress) }
}
