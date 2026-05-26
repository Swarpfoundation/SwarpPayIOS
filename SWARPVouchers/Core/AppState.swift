import Foundation
import SwiftUI

final class AppState: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedTab: AppTab = .home
    let shouldShowLaunchIntro: Bool
    let api: APIClient
    let keychain: SecureSessionStore
    private let routeParser = DeepLinkRouter()

    init(
        api: APIClient = AppEnvironment.current.api,
        keychain: SecureSessionStore = KeychainSessionStore(),
        launchArguments: [String] = ProcessInfo.processInfo.arguments
    ) {
        self.api = api
        self.keychain = keychain
        self.shouldShowLaunchIntro = !launchArguments.contains("--swarp-skip-intro")
        applyLaunchArguments(launchArguments)
    }

    func startConsumerFlow() {
        path = NavigationPath()
        selectedTab = .home
    }

    #if DEBUG
    func completeDemoAuth() {
        try? keychain.save(sessionHandle: "debug-session-\(UUID().uuidString)")
        path = NavigationPath()
        selectedTab = .home
    }
    #endif

    func clearLocalSession() {
        try? keychain.clear()
        path = NavigationPath()
        selectedTab = .home
    }

    func navigate(to route: AppRoute) {
        apply(route: route)
    }

    func select(tab: AppTab) {
        path = NavigationPath()
        selectedTab = tab
    }

    func handle(url: URL) {
        guard let route = routeParser.route(for: url) else { return }
        apply(route: route)
    }

    private func applyLaunchArguments(_ arguments: [String]) {
        guard AppEnvironment.current.features.demoFixturesEnabled else { return }
        #if DEBUG
        guard
            let routeFlagIndex = arguments.firstIndex(of: "--swarp-demo-route"),
            arguments.indices.contains(routeFlagIndex + 1)
        else { return }

        let routeValue = arguments[routeFlagIndex + 1]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard
            !routeValue.isEmpty,
            let url = URL(string: "https://swarpvouchers.local/\(routeValue)"),
            let route = routeParser.route(for: url)
        else { return }

        apply(route: route)
        #endif
    }

    private func apply(route: AppRoute) {
        path = NavigationPath()
        switch route {
        case .home, .onboarding, .login, .register:
            selectedTab = .home
        case .catalog, .category:
            selectedTab = .catalog
            if case .category = route {
                path.append(route)
            }
        case .orders:
            selectedTab = .vouchers
        case .support:
            selectedTab = .support
        case .profile, .kyc:
            selectedTab = .profile
        case .product, .checkout, .receipt, .claim:
            path.append(route)
        }
    }
}
