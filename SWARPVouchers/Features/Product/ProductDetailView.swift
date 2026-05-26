import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject private var appState: AppState
    let productId: String
    @State private var selectedDenominationMinor: Int

    private var product: VoucherProduct? { InternalDemoData.product(id: productId) }

    init(productId: String) {
        self.productId = productId
        _selectedDenominationMinor = State(initialValue: InternalDemoData.product(id: productId)?.defaultAmountMinor ?? 0)
    }

    var body: some View {
        StackScreenScaffold(title: "Voucher detail", showsRightActions: true) {
            if let product {
            PremiumVoucherCard(product: product, amountMinor: selectedDenominationMinor, compact: true)

            SectionHeader(title: "Available denominations")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(product.denominationsMinor.prefix(4), id: \.self) { amount in
                    DenominationButton(
                        amountMinor: amount,
                        label: product.denominationLabel(for: amount),
                        isSelected: selectedDenominationMinor == amount
                    ) {
                        selectedDenominationMinor = amount
                    }
                }
            }

            SectionHeader(title: "Voucher details")
            SurfaceCard {
                VStack(spacing: 0) {
                    InfoRow(symbolName: "gift", label: "Delivery", value: "Digital")
                    Divider().overlay(.white.opacity(0.08))
                    InfoRow(symbolName: "shield.checkered", label: "Verification required", value: product.tier)
                    Divider().overlay(.white.opacity(0.08))
                    InfoRow(symbolName: "ticket", label: "Terms / redemption notes", value: "View", showsChevron: true)
                }
            }

            SectionHeader(title: "Redemption notes")
            SurfaceCard {
                Text(product.notes)
                    .font(.subheadline)
                    .lineSpacing(4)
                    .foregroundStyle(SWARPColor.coolGray)
            }
            } else {
                FeatureUnavailableCard(
                    title: "Voucher details unavailable",
                    message: "This build has no production catalog backend configured. Voucher details are disabled until server-verified inventory is available.",
                    symbolName: "ticket"
                )
            }
        } bottomBar: {
            if let product, AppEnvironment.current.features.checkoutEnabled {
                CTAButton(title: "Continue to checkout", subtitle: "Internal demo only") {
                    appState.path.append(AppRoute.checkout(product.id))
                }
            } else {
                CTAButton(title: "Checkout unavailable", subtitle: "Backend verification required", symbolName: "lock.fill") { }
            }
        }
    }
}
