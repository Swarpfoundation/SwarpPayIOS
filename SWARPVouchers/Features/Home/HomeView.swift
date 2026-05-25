import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dashboardVisible = false
    private let products = DemoFixtures.products
    private let orders = DemoFixtures.orders
    private let session = DemoFixtures.session(email: "eddine@swarppay.app")

    private var activeOrders: [VoucherOrder] {
        orders.filter { $0.status == "Active" }
    }

    private var activeValueMinor: Int {
        activeOrders.reduce(0) { $0 + $1.amountMinor }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SWARPSpacing.md) {
            DashboardGreeting(name: session.displayName)

            WalletHeroCard(
                activeValueMinor: activeValueMinor,
                activeCount: activeOrders.count,
                kyc: session.kyc,
                claimAction: { appState.path.append(AppRoute.claim("SPAY-8K72-MAD")) },
                browseAction: { appState.selectedTab = .catalog }
            )
            .opacity(dashboardVisible ? 1 : 0)
            .offset(y: dashboardVisible || reduceMotion ? 0 : 16)

            SectionHeader(title: "Quick actions")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                QuickActionTile(title: "Browse", symbolName: "ticket", detail: "Find vouchers") {
                    appState.selectedTab = .catalog
                }
                QuickActionTile(title: "My vouchers", symbolName: "rectangle.stack", detail: "Active & receipts") {
                    appState.selectedTab = .vouchers
                }
                QuickActionTile(title: "Claim", symbolName: "gift", detail: "Use a voucher link") {
                    appState.path.append(AppRoute.claim("SPAY-8K72-MAD"))
                }
                QuickActionTile(title: "Support", symbolName: "headphones", detail: "Get help") {
                    appState.selectedTab = .support
                }
            }

            SectionHeader(title: "Featured vouchers", actionTitle: "See all") {
                appState.selectedTab = .catalog
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(products.prefix(6)) { product in
                        VoucherMiniCard(product: product) {
                            appState.path.append(AppRoute.product(product.id))
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            SectionHeader(title: "Recent activity")
            VStack(spacing: 10) {
                ForEach(orders.prefix(3)) { order in
                    RecentActivityRow(order: order) {
                        if let receiptId = order.receiptId {
                            appState.path.append(AppRoute.receipt(receiptId))
                        } else {
                            appState.selectedTab = .vouchers
                        }
                    }
                }
            }
        }
        .onAppear {
            guard !dashboardVisible else { return }
            if reduceMotion {
                dashboardVisible = true
            } else {
                withAnimation(SWARPMotion.enter) {
                    dashboardVisible = true
                }
            }
        }
    }
}

private struct DashboardGreeting: View {
    let name: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Good evening, \(name)")
                .font(.title2.bold())
                .foregroundStyle(SWARPColor.cream)
            Text("Manage demo vouchers, claims, and receipts from one place.")
                .font(.subheadline)
                .foregroundStyle(SWARPColor.coolGray)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct WalletHeroCard: View {
    let activeValueMinor: Int
    let activeCount: Int
    let kyc: KycTierStatus
    let claimAction: () -> Void
    let browseAction: () -> Void

    private var activeValue: String {
        "\(activeValueMinor / 100) MAD"
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: SWARPRadius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            SWARPColor.electricBlue.opacity(0.34),
                            SWARPColor.panel.opacity(0.96),
                            SWARPColor.deepest.opacity(0.96)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(SWARPColor.signal.opacity(0.12))
                .frame(width: 190, height: 190)
                .blur(radius: 4)
                .offset(x: 70, y: -76)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: SWARPSpacing.lg) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Voucher wallet")
                            .font(SWARPType.eyebrow)
                            .textCase(.uppercase)
                            .foregroundStyle(SWARPColor.minted)
                        Text(activeValue)
                            .font(.largeTitle.bold())
                            .foregroundStyle(SWARPColor.cream)
                            .contentTransition(.numericText())
                        Text("\(activeCount) active voucher\(activeCount == 1 ? "" : "s") ready in demo mode")
                            .font(.subheadline)
                            .foregroundStyle(SWARPColor.coolGray)
                    }
                    Spacer()
                    BrandedIcon(symbolName: "wallet.pass.fill", size: 58, accent: SWARPColor.minted)
                }

                LimitProgress(title: "Daily limit", usedMinor: kyc.usedTodayMinor, limitMinor: kyc.dailyLimitMinor, currency: "MAD")

                HStack(spacing: 10) {
                    Button {
                        Haptics.lightImpact()
                        claimAction()
                    } label: {
                        Label("Claim voucher", systemImage: "gift.fill")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .foregroundStyle(.white)
                            .background(LinearGradient.swarpPrimaryAction)
                            .clipShape(RoundedRectangle(cornerRadius: SWARPRadius.md, style: .continuous))
                    }
                    .buttonStyle(PressableScale())

                    Button {
                        Haptics.selection()
                        browseAction()
                    } label: {
                        Label("Browse", systemImage: "ticket.fill")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .foregroundStyle(SWARPColor.cream)
                            .background(.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: SWARPRadius.md, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: SWARPRadius.md)
                                    .stroke(.white.opacity(0.10), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PressableScale())
                }
            }
            .padding(SWARPSpacing.lg)
        }
        .overlay(
            RoundedRectangle(cornerRadius: SWARPRadius.xl, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: SWARPColor.electricBlue.opacity(0.20), radius: 30, x: 0, y: 18)
    }
}

private struct RecentActivityRow: View {
    let order: VoucherOrder
    let action: () -> Void

    private var product: VoucherProduct { DemoFixtures.product(id: order.productId) }
    private var statusTone: Color { order.status == "Delivered" ? SWARPColor.success : SWARPColor.gold }

    var body: some View {
        Button(action: action) {
            SurfaceCard(padding: 12, cornerRadius: SWARPRadius.lg, prominence: .subtle) {
                HStack(spacing: 12) {
                    BrandOrb(product: product, size: 48)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.productTitle)
                            .font(.subheadline.bold())
                            .foregroundStyle(SWARPColor.cream)
                            .lineLimit(1)
                        Text("\(order.formattedAmount) · \(order.date)")
                            .font(.caption)
                            .foregroundStyle(SWARPColor.coolGray)
                            .lineLimit(1)
                    }
                    Spacer()
                    StatusBadge(title: order.status, tone: statusTone)
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(SWARPColor.coolGray.opacity(0.55))
                }
            }
        }
        .buttonStyle(PressableScale())
    }
}

private struct MiniOrderCard: View {
    let order: VoucherOrder
    let action: () -> Void

    private var product: VoucherProduct { DemoFixtures.product(id: order.productId) }

    var body: some View {
        Button(action: action) {
            SurfaceCard(padding: 12) {
                HStack(spacing: 12) {
                    BrandOrb(product: product, size: 46)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.productTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SWARPColor.cream)
                            .lineLimit(1)
                        Text("\(order.status) · View receipt")
                            .font(.caption)
                            .foregroundStyle(SWARPColor.coolGray.opacity(0.72))
                    }
                    Spacer()
                    StatusBadge(title: order.status, tone: order.status == "Delivered" ? SWARPColor.success : SWARPColor.signal)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SWARPColor.coolGray.opacity(0.55))
                }
            }
        }
        .buttonStyle(PressableScale())
    }
}
