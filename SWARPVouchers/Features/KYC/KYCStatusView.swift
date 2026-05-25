import SwiftUI

struct KYCStatusView: View {
    private let kyc = DemoFixtures.session(email: "demo@example.test").kyc

    var body: some View {
        ScreenScaffold(title: "Verification", subtitle: "Check your current voucher limits and upgrade when you need more access.") {
            VStack(spacing: SWARPSpacing.md) {
                KycLimitCard(kyc: kyc)
                MetricCard(label: "Tier", value: kyc.tier, detail: kyc.status)
                MetricCard(label: "Daily limit left", value: kyc.formattedDailyRemaining, detail: "Used today: \(kyc.usedTodayMinor / 100) MAD")
                MetricCard(label: "Monthly usage", value: "\(kyc.usedMonthMinor / 100) MAD", detail: "Monthly cap: \(kyc.monthlyLimitMinor / 100) MAD")
                InfoCard {
                    Text("Next step")
                        .font(.headline)
                        .foregroundStyle(SWARPColor.cream)
                    Text("Higher limits may require a verified ID and a few account details.")
                        .foregroundStyle(SWARPColor.coolGray)
                }
                PrimaryButton(title: "Upgrade verification") { }
            }
        }
    }
}
