import SwiftUI

struct ClaimPreviewView: View {
    @EnvironmentObject private var appState: AppState
    @State private var readyVisible = false
    let linkValue: String

    private var preview: ClaimPreview {
        DemoFixtures.claimPreview(reference: linkValue)
    }

    private var product: VoucherProduct {
        DemoFixtures.product(id: preview.productId)
    }

    var body: some View {
        StackScreenScaffold(title: "Claim voucher") {
            VStack(alignment: .leading, spacing: 6) {
                Text("Claim voucher")
                    .font(.system(size: 26, weight: .semibold))
                    .tracking(-0.9)
                    .foregroundStyle(SWARPColor.cream)
                Text("Preview and claim a voucher shared with you.")
                    .font(.subheadline)
                    .foregroundStyle(SWARPColor.coolGray.opacity(0.72))
            }

            PremiumVoucherCard(product: product, amountMinor: preview.amountMinor, compact: true)

            SectionHeader(title: "Claim code")
            SurfaceCard {
                Text(preview.reference)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .tracking(3)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(SWARPColor.cream)
                    .multilineTextAlignment(.center)
            }

            SurfaceCard {
                HStack(spacing: 12) {
                    BrandedIcon(symbolName: "checkmark.seal.fill", size: 42, accent: SWARPColor.success)
                        .scaleEffect(readyVisible ? 1 : 0.82)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preview.status)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SWARPColor.cream)
                        Text("Digital delivery will appear in My Vouchers.")
                            .font(.caption)
                            .foregroundStyle(SWARPColor.coolGray)
                    }
                }
            }

            CTAButton(title: "Claim voucher", symbolName: "gift.fill") {
                Haptics.success()
                appState.selectedTab = .vouchers
                if !appState.path.isEmpty {
                    appState.path.removeLast()
                }
            }
            .padding(.top, SWARPSpacing.md)
        }
        .onAppear {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.76).delay(0.12)) {
                readyVisible = true
            }
        }
    }
}
