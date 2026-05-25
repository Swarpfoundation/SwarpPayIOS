import SwiftUI

struct SupportView: View {
    let reference: String?

    var body: some View {
        VStack(alignment: .leading, spacing: SWARPSpacing.md) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Support")
                    .font(.system(size: 26, weight: .semibold))
                    .tracking(-0.9)
                    .foregroundStyle(SWARPColor.cream)
                Text("Help with purchases, delivery, claims, verification, and receipts.")
                    .font(.subheadline)
                    .foregroundStyle(SWARPColor.coolGray.opacity(0.72))
            }

            VStack(spacing: 12) {
                SupportOptionCard(title: "Purchase help", bodyText: "Questions about payment, total, delivery, or voucher availability.")
                SupportOptionCard(title: "Claim issue", bodyText: "A shared voucher code does not open, match, or redeem correctly.")
                SupportOptionCard(title: "Verification and limits", bodyText: "Questions about Tier 1, Tier 2, and daily purchase limits.")
                SupportOptionCard(title: "Receipt request", bodyText: "Find a receipt or ask about a delivered order.")
            }
        }
    }
}
