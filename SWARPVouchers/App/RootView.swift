import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingLaunchIntro = true

    var body: some View {
        NavigationStack(path: $appState.path) {
            ConsumerAppShell()
                .navigationDestination(for: AppRoute.self) { route in
                    route.destination
                }
        }
        .tint(SWARPColor.signal)
        .overlay {
            if showingLaunchIntro && appState.shouldShowLaunchIntro {
                LaunchIntroView {
                    withAnimation(.easeInOut(duration: 0.26)) {
                        showingLaunchIntro = false
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

struct LaunchIntroView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var logoVisible = false
    @State private var wordmarkVisible = false
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            LaunchBackground()
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(SWARPColor.signal.opacity(0.08))
                        .frame(width: 156, height: 156)
                        .overlay(Circle().stroke(SWARPColor.signal.opacity(0.18), lineWidth: 1))
                        .shadow(color: SWARPColor.signal.opacity(0.24), radius: 34, x: 0, y: 0)
                    LogoMark(size: logoVisible ? 116 : 92, glow: true)
                }
                .opacity(logoVisible ? 1 : 0)
                .scaleEffect(logoVisible ? 1 : 0.90)
                VStack(spacing: 6) {
                    Text("SwarpPay")
                        .font(.system(size: 34, weight: .semibold, design: .serif))
                        .tracking(-0.8)
                        .foregroundStyle(SWARPColor.cream)
                    Text("Digital vouchers")
                        .font(.caption.weight(.semibold))
                        .tracking(1.6)
                        .textCase(.uppercase)
                        .foregroundStyle(SWARPColor.signal.opacity(0.82))
                }
                .opacity(wordmarkVisible ? 1 : 0)
                .offset(y: wordmarkVisible ? 0 : 8)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if reduceMotion {
                logoVisible = true
                wordmarkVisible = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.65, execute: onComplete)
            } else {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                    logoVisible = true
                }
                withAnimation(.easeOut(duration: 0.38).delay(0.38)) {
                    wordmarkVisible = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.45, execute: onComplete)
            }
        }
    }
}

private struct LaunchBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [SWARPColor.deepest, SWARPColor.primaryDark, SWARPColor.ink],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [SWARPColor.signal.opacity(0.20), .clear],
                center: UnitPoint(x: 0.5, y: 0.36),
                startRadius: 4,
                endRadius: 320
            )
        }
    }
}

enum AppRoute: Hashable {
    case onboarding
    case login
    case register
    case home
    case catalog
    case category(VoucherCategory)
    case product(String)
    case checkout(String)
    case kyc
    case orders
    case receipt(String)
    case claim(String)
    case support(String?)
    case profile

    @ViewBuilder
    var destination: some View {
        switch self {
        case .onboarding, .login, .register, .home:
            ConsumerAppShell()
        case .catalog:
            CatalogView()
        case .category(let category):
            CatalogView(initialCategory: category)
        case .product(let id): ProductDetailView(productId: id)
        case .checkout(let id): CheckoutView(productId: id)
        case .kyc:
            ProfileView()
        case .orders:
            MyVouchersView()
        case .receipt(let id): ReceiptDetailView(receiptId: id)
        case .claim(let value): ClaimPreviewView(linkValue: value)
        case .support(let reference): SupportView(reference: reference)
        case .profile: ProfileView()
        }
    }
}

struct ConsumerAppShell: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: SWARPSpacing.md) {
                    tabContent
                }
                .padding(.horizontal, SWARPSpacing.md)
                .padding(.top, SWARPSpacing.xs)
                .padding(.bottom, SWARPSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .animation(.easeInOut(duration: 0.20), value: appState.selectedTab)
            BottomTabBar(selectedTab: $appState.selectedTab)
        }
        .premiumBackground()
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack(spacing: SWARPSpacing.md) {
            ProfileAvatarButton(isSelected: appState.selectedTab == .profile) {
                withAnimation(SWARPMotion.smooth) {
                    appState.selectedTab = .profile
                }
            }
            if appState.selectedTab != .home {
                VStack(alignment: .leading, spacing: 3) {
                    Text(appState.selectedTab.headerTitle)
                        .font(.headline.bold())
                        .foregroundStyle(SWARPColor.cream)
                        .lineLimit(1)
                    Text(appState.selectedTab.headerSubtitle)
                        .font(.caption)
                        .foregroundStyle(SWARPColor.coolGray)
                        .lineLimit(1)
                }
            }
            Spacer()
            IconCircleButton(symbolName: "bell", accessibilityLabel: "Notifications")
        }
        .padding(.horizontal, SWARPSpacing.md)
        .padding(.top, 12)
        .padding(.bottom, SWARPSpacing.sm)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch appState.selectedTab {
        case .home:
            HomeView()
        case .catalog:
            CatalogView()
        case .vouchers:
            MyVouchersView()
        case .support:
            SupportView(reference: nil)
        case .profile:
            ProfileView()
        }
    }
}

private struct ProfileAvatarButton: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.lightImpact()
            action()
        } label: {
            Image("EddineProfile")
                .resizable()
                .scaledToFill()
                .frame(width: 38, height: 38)
                .clipShape(Circle())
                .background(
                    Circle()
                        .fill(isSelected ? SWARPColor.signal.opacity(0.12) : .white.opacity(0.06))
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? SWARPColor.signal.opacity(0.38) : .white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: isSelected ? SWARPColor.signal.opacity(0.24) : .black.opacity(0.18), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("Profile")
    }
}

private extension AppTab {
    var headerTitle: String {
        switch self {
        case .home: "Manage vouchers"
        case .catalog: "Browse catalog"
        case .vouchers: "Your vouchers"
        case .support: "Support"
        case .profile: "Profile"
        }
    }

    var headerSubtitle: String {
        switch self {
        case .home: "Claim, track, and redeem"
        case .catalog: "Find brands and categories"
        case .vouchers: "Active codes and receipts"
        case .support: "Help with orders and claims"
        case .profile: "Account and preferences"
        }
    }
}

struct StackScreenScaffold<Content: View>: View {
    @EnvironmentObject private var appState: AppState
    let title: String
    var showsRightActions = false
    let content: Content
    let bottomBar: AnyView?

    init(title: String, showsRightActions: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.showsRightActions = showsRightActions
        self.content = content()
        self.bottomBar = nil
    }

    init<BottomBar: View>(
        title: String,
        showsRightActions: Bool = false,
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottomBar: () -> BottomBar
    ) {
        self.title = title
        self.showsRightActions = showsRightActions
        self.content = content()
        self.bottomBar = AnyView(bottomBar())
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: SWARPSpacing.sm) {
                IconCircleButton(symbolName: "chevron.left") {
                    if !appState.path.isEmpty {
                        appState.path.removeLast()
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SWARPColor.cream)
                        .lineLimit(1)
                    Text("SwarpPay")
                        .font(.caption2)
                        .foregroundStyle(SWARPColor.coolGray.opacity(0.72))
                }
                Spacer()
                if showsRightActions {
                    IconCircleButton(symbolName: "square.and.arrow.up")
                    IconCircleButton(symbolName: "heart")
                }
            }
            .padding(.horizontal, SWARPSpacing.md)
            .padding(.top, 12)
            .padding(.bottom, SWARPSpacing.sm)

            ScrollView {
                VStack(spacing: SWARPSpacing.md) {
                    content
                }
                .padding(.horizontal, SWARPSpacing.md)
                .padding(.bottom, bottomBar == nil ? SWARPSpacing.xl : 120)
            }
            .scrollIndicators(.hidden)

            if let bottomBar {
                bottomBar
                    .padding(.horizontal, SWARPSpacing.md)
                    .padding(.top, SWARPSpacing.sm)
                    .padding(.bottom, 12)
                    .background(.black.opacity(0.72))
                    .overlay(Rectangle().fill(.white.opacity(0.08)).frame(height: 1), alignment: .top)
            }
        }
        .premiumBackground()
        .navigationBarBackButtonHidden(true)
    }
}
