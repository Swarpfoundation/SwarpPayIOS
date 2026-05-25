import SwiftUI

struct ReceiptDetailView: View {
    let receiptId: String

    private var receipt: Receipt {
        DemoFixtures.receipt(id: receiptId)
    }

    private var product: VoucherProduct {
        DemoFixtures.product(id: receipt.productId)
    }

    var body: some View {
        StackScreenScaffold(title: "Receipt") {
            ReceiptCard(receipt: receipt, product: product)
            NeedHelpReceiptCard()
        }
    }
}

private struct ReceiptCard: View {
    let receipt: Receipt
    let product: VoucherProduct
    @State private var successVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [SWARPColor.signal.opacity(0.32), .clear, SWARPColor.signal.opacity(0.20)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 10)

            VStack(spacing: SWARPSpacing.md) {
                ZStack {
                    Circle()
                        .fill(SWARPColor.success.opacity(0.09))
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(SWARPColor.success)
                }
                .frame(width: 64, height: 64)
                .overlay(Circle().stroke(SWARPColor.success.opacity(0.22), lineWidth: 1))
                .shadow(color: SWARPColor.success.opacity(0.18), radius: 24, x: 0, y: 10)
                .scaleEffect(successVisible ? 1 : 0.74)
                .opacity(successVisible ? 1 : 0)

                Text("Payment successful")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(SWARPColor.cream)
                    .opacity(successVisible ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SWARPSpacing.lg)

            VStack(spacing: 0) {
                ReceiptRow(label: "Receipt reference", value: receipt.reference)
                ReceiptRow(label: "Product", value: receipt.productTitle)
                ReceiptRow(label: "Amount", value: "\(receipt.amountMinor / 100) \(receipt.currency)")
                ReceiptRow(label: "Status", value: receipt.status, isSuccess: true)
                ReceiptRow(label: "Date", value: receipt.issuedAt)
            }
            .padding(.horizontal, SWARPSpacing.md)

            VStack(spacing: 12) {
                Text("Your voucher has been delivered.\nThank you for using SwarpPay.")
                    .font(.subheadline)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SWARPColor.coolGray)
                Image(systemName: "sparkles")
                    .foregroundStyle(SWARPColor.signal)
            }
            .frame(maxWidth: .infinity)
            .padding(SWARPSpacing.lg)
            .overlay(alignment: .top) {
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .foregroundStyle(.white.opacity(0.14))
                    .frame(height: 1)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x3B82F6).opacity(0.12), SWARPColor.primaryDark.opacity(0.88), .black.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 26).stroke(SWARPColor.signal.opacity(0.18), lineWidth: 1))
                .shadow(color: Color(hex: 0x1D4ED8).opacity(0.16), radius: 28, x: 0, y: 18)
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .onAppear {
            Haptics.success()
            withAnimation(.spring(response: 0.36, dampingFraction: 0.72).delay(0.08)) {
                successVisible = true
            }
        }
    }
}

private struct ReceiptRow: View {
    let label: String
    let value: String
    var isSuccess = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(label)
                .font(.caption)
                .foregroundStyle(SWARPColor.coolGray.opacity(0.74))
            Spacer()
            Text(value)
                .font(.caption.weight(.bold))
                .multilineTextAlignment(.trailing)
                .foregroundStyle(isSuccess ? SWARPColor.success : SWARPColor.cream)
                .lineLimit(2)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle().fill(.white.opacity(0.08)).frame(height: 1)
        }
    }
}

private struct NeedHelpReceiptCard: View {
    var body: some View {
        SurfaceCard(padding: 14) {
            HStack(spacing: 12) {
                BrandedIcon(symbolName: "headphones", size: 42)
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
    }
}
