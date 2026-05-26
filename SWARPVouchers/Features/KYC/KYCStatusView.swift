import SwiftUI

struct KYCStatusView: View {
    private var kyc: KycTierStatus? { InternalDemoData.session()?.kyc }

    var body: some View {
        ScreenScaffold(title: "Verification", subtitle: "Check your current voucher limits and upgrade when you need more access.") {
            VStack(spacing: SWARPSpacing.md) {
                if let kyc, AppEnvironment.current.features.demoFixturesEnabled {
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
                } else {
                    FeatureUnavailableCard(
                        title: "Verification unavailable",
                        message: "KYC status and limits require backend authority and are disabled in this build. No verified status is stored locally.",
                        symbolName: "shield.checkered"
                    )
                }
            }
        }
    }
}
