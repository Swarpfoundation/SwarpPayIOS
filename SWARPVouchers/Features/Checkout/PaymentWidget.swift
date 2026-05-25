import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var appState: AppState
    let productId: String
    @State private var selectedDenominationMinor: Int

    private var product: VoucherProduct {
        DemoFixtures.product(id: productId)
    }

    private var serviceFeeMinor: Int {
        max(500, Int((Double(selectedDenominationMinor) * 0.025).rounded()))
    }

    init(productId: String) {
        self.productId = productId
        let product = DemoFixtures.product(id: productId)
        _selectedDenominationMinor = State(initialValue: product.defaultAmountMinor)
    }

    var body: some View {
        StackScreenScaffold(title: "Checkout") {
            VStack(alignment: .leading, spacing: 6) {
                Text("Selected voucher")
                    .font(.caption.weight(.bold))
                    .tracking(1.4)
                    .textCase(.uppercase)
                    .foregroundStyle(SWARPColor.signal.opacity(0.78))
                SelectedVoucherCard(product: product, amountMinor: selectedDenominationMinor)
            }

            SectionHeader(title: "Denomination")
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

            SectionHeader(title: "Verification & limit")
            CheckoutVerificationCard()

            SectionHeader(title: "Payment method")
            PaymentMethodCard()

            SurfaceCard(padding: 12) {
                HStack(spacing: 10) {
                    LogoMark(size: 24, glow: true)
                    Text("Protected SwarpPay checkout")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SWARPColor.coolGray)
                    Spacer()
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(SWARPColor.signal)
                }
            }

            SectionHeader(title: "Price breakdown")
            PriceBreakdownCard(subtotalMinor: selectedDenominationMinor, serviceFeeMinor: serviceFeeMinor, currency: product.currency)

            NeedHelpCard()
        } bottomBar: {
            CTAButton(
                title: "Confirm purchase",
                subtitle: "Total \(money(selectedDenominationMinor + serviceFeeMinor))",
                symbolName: "lock.fill"
            ) {
                Haptics.success()
                appState.path.append(AppRoute.receipt(receiptIdForProduct(product.id)))
            }
        }
    }

    private func money(_ minor: Int) -> String {
        String(format: "%.2f %@", Double(minor) / 100.0, product.currency)
    }

    private func receiptIdForProduct(_ id: String) -> String {
        "receipt-\(id)"
    }
}

private struct SelectedVoucherCard: View {
    let product: VoucherProduct
    let amountMinor: Int

    var body: some View {
        SurfaceCard(padding: 12) {
            HStack(spacing: 12) {
                BrandOrb(product: product, size: 46)
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.brand)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SWARPColor.cream)
                        .lineLimit(1)
                    Label(product.delivery, systemImage: "bolt.fill")
                        .font(.caption2)
                        .foregroundStyle(SWARPColor.coolGray.opacity(0.75))
                }
                Spacer()
                Text(product.denominationLabel(for: amountMinor))
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .foregroundStyle(.white)
                    .background(SWARPColor.signal.opacity(0.10))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(SWARPColor.signal.opacity(0.22), lineWidth: 1))
            }
        }
    }
}

private struct CheckoutVerificationCard: View {
    var body: some View {
        SurfaceCard(padding: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(hex: 0x3B82F6).opacity(0.12))
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(SWARPColor.signal)
                }
                .frame(width: 46, height: 46)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Tier 2 approved")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SWARPColor.cream)
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(SWARPColor.signal)
                    }
                    Text("Daily limit: 1,250 / 5,000 MAD")
                        .font(.caption2)
                        .foregroundStyle(SWARPColor.coolGray)
                    ProgressBar(progress: 0.25)
                }
            }
        }
    }
}

private struct NeedHelpCard: View {
    var body: some View {
        SurfaceCard(padding: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(SWARPColor.signal.opacity(0.08))
                    Image(systemName: "headphones")
                        .foregroundStyle(SWARPColor.signal)
                }
                .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Need help?")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SWARPColor.cream)
                    Text("Chat with our support team")
                        .font(.caption2)
                        .foregroundStyle(SWARPColor.coolGray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(SWARPColor.coolGray.opacity(0.55))
            }
        }
        .padding(.top, SWARPSpacing.sm)
    }
}
