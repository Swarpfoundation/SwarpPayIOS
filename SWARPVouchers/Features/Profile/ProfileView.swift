import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    private let session = InternalDemoData.session()
    private let recentOrder = InternalDemoData.orders.first
    private let recentReceipt = InternalDemoData.receipts.first

    var body: some View {
        VStack(alignment: .leading, spacing: SWARPSpacing.md) {
            ProfileHero(name: session?.displayName ?? "SwarpPay")

            if let session, AppEnvironment.current.features.demoFixturesEnabled {
            SectionHeader(title: "Account health")
            AccountHealthCard(kyc: session.kyc)

            SectionHeader(title: "Recent activity")
            ProfileSectionCard {
                if let recentOrder {
                ProfileActionRow(
                    symbolName: "bag.fill",
                    title: "Last order",
                    subtitle: "\(recentOrder.productTitle) · \(recentOrder.formattedAmount)",
                    value: recentOrder.status
                )
                }
                if let recentReceipt {
                ProfileActionRow(
                    symbolName: "doc.text.fill",
                    title: "Last receipt",
                    subtitle: recentReceipt.reference,
                    value: "Available"
                )
                }
                ProfileActionRow(
                    symbolName: "gift.fill",
                    title: "Last claim",
                    subtitle: "Shared voucher preview",
                    value: "Ready"
                )
            }

            SectionHeader(title: "Delivery preferences")
            ProfileSectionCard {
                ProfileActionRow(symbolName: "envelope.fill", title: "Email", subtitle: session.email, value: "On")
                ProfileActionRow(symbolName: "message.fill", title: "SMS", subtitle: "Delivery alerts", value: "Off")
                ProfileActionRow(symbolName: "bell.fill", title: "App notifications", subtitle: "Orders and receipts", value: "On")
            }

            SectionHeader(title: "Security")
            ProfileSectionCard {
                ProfileActionRow(symbolName: "faceid", title: "Face ID", subtitle: "Fast app unlock", value: "Ready")
                ProfileActionRow(symbolName: "lock.fill", title: "Passcode", subtitle: "Required for purchase confirmation", value: "On")
                ProfileActionRow(symbolName: "iphone.gen3", title: "Trusted device", subtitle: "This iPhone", value: "Active")
            }
            } else {
                FeatureUnavailableCard(
                    title: "Profile unavailable",
                    message: "Profile, KYC, order, and receipt data require backend authority and are disabled in this build. No local authenticated state exists.",
                    symbolName: "person.crop.circle.badge.exclamationmark"
                )
            }

            SectionHeader(title: "Support")
            SupportStatusCard {
                appState.selectedTab = .support
            }

            if let session, AppEnvironment.current.features.demoFixturesEnabled {
            SectionHeader(title: "Personal details")
            ProfileSectionCard {
                ProfileActionRow(symbolName: "person.fill", title: "Name", subtitle: "Profile display name", value: session.displayName)
                ProfileActionRow(symbolName: "at", title: "Email", subtitle: "Account contact", value: session.email)
                ProfileActionRow(symbolName: "mappin.and.ellipse", title: "Region", subtitle: "Voucher catalog region", value: "Morocco")
            }

            SectionHeader(title: "App settings")
            ProfileSectionCard {
                ProfileActionRow(symbolName: "globe", title: "Language", subtitle: "App language", value: "English")
                ProfileActionRow(symbolName: "dollarsign.circle.fill", title: "Currency", subtitle: "Purchase display", value: "MAD")
                ProfileActionRow(symbolName: "bell.badge.fill", title: "Notifications", subtitle: "Delivery and support updates", value: "Enabled")
            }
            }

            if AppEnvironment.current.features.demoAuthEnabled {
                SecondaryButton(title: "Clear local session") {
                    appState.clearLocalSession()
                }
            }
        }
        .privacySensitive()
    }
}

private struct ProfileHero: View {
    let name: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(SWARPColor.signal.opacity(0.10))
                Image("EddineProfile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 68, height: 68)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: [.black.opacity(0.02), SWARPColor.deepest.opacity(0.20)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    )
            }
            .frame(width: 68, height: 68)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(SWARPColor.signal.opacity(0.22), lineWidth: 1))
            .shadow(color: SWARPColor.signal.opacity(0.14), radius: 22, x: 0, y: 12)

            VStack(alignment: .leading, spacing: 5) {
                Text(name)
                    .font(.system(size: 26, weight: .semibold))
                    .tracking(-0.8)
                    .foregroundStyle(SWARPColor.cream)
                Text("SwarpPay account")
                    .font(.subheadline)
                    .foregroundStyle(SWARPColor.coolGray.opacity(0.72))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [SWARPColor.signal.opacity(0.13), Color(hex: 0x172554).opacity(0.46), .black.opacity(0.32)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(SWARPColor.signal.opacity(0.18), lineWidth: 1))
                .shadow(color: Color(hex: 0x1D4ED8).opacity(0.16), radius: 24, x: 0, y: 16)
        )
    }
}

private struct AccountHealthCard: View {
    let kyc: KycTierStatus
    @State private var animatedProgress = 0.0

    var body: some View {
        SurfaceCard(padding: 16) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    BrandedIcon(symbolName: "checkmark.shield.fill", size: 44)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(kyc.tier) approved")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(SWARPColor.cream)
                        Text("Daily limit: \(kyc.usedTodayMinor / 100) / \(kyc.dailyLimitMinor / 100) MAD")
                            .font(.caption)
                            .foregroundStyle(SWARPColor.coolGray)
                    }
                    Spacer()
                    Text("Healthy")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SWARPColor.success)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(SWARPColor.success.opacity(0.10), in: Capsule())
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.08))
                        Capsule()
                            .fill(LinearGradient(colors: [SWARPColor.signal, Color(hex: 0x3B82F6)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: proxy.size.width * animatedProgress)
                    }
                }
                .frame(height: 7)

                HStack(spacing: 10) {
                    HealthStat(title: "Verification", value: kyc.tier)
                    HealthStat(title: "Daily limit", value: "\(kyc.dailyLimitMinor / 100) MAD")
                    HealthStat(title: "Receipts", value: "Enabled")
                }
            }
        }
        .onAppear {
            let progress = Double(kyc.usedTodayMinor) / Double(max(kyc.dailyLimitMinor, 1))
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                animatedProgress = min(max(progress, 0), 1)
            }
        }
    }
}

private struct HealthStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SWARPColor.coolGray.opacity(0.82))
                .lineLimit(1)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(SWARPColor.cream)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 1))
    }
}

private struct ProfileSectionCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        SurfaceCard {
            VStack(spacing: 0) {
                content
            }
        }
    }
}

private struct ProfileActionRow: View {
    let symbolName: String
    let title: String
    let subtitle: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            BrandedIcon(symbolName: symbolName, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SWARPColor.cream)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(SWARPColor.coolGray.opacity(0.78))
                    .lineLimit(1)
            }
            Spacer(minLength: 12)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(SWARPColor.cream)
                .lineLimit(1)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Divider().overlay(.white.opacity(0.08)).padding(.leading, 50)
        }
    }
}

private struct SupportStatusCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.selection()
            action()
        }) {
            HStack(spacing: 12) {
                BrandedIcon(symbolName: "headphones", size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text("No active tickets")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SWARPColor.cream)
                    Text("Support is ready for purchases, claims, receipts, and verification.")
                        .font(.caption)
                        .foregroundStyle(SWARPColor.coolGray.opacity(0.78))
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SWARPColor.coolGray.opacity(0.58))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.045))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.10), lineWidth: 1))
            )
        }
        .buttonStyle(PressableScale())
    }
}
