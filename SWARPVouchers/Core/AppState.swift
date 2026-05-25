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
        api: APIClient = DemoAPIClient(),
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

    func completeDemoAuth() {
        try? keychain.save(sessionHandle: "swarppay-session")
        path = NavigationPath()
        selectedTab = .home
    }

    func handle(url: URL) {
        guard let route = routeParser.route(for: url) else { return }
        apply(route: route)
    }

    private func applyLaunchArguments(_ arguments: [String]) {
        guard
            let routeFlagIndex = arguments.firstIndex(of: "--swarp-demo-route"),
            arguments.indices.contains(routeFlagIndex + 1)
        else { return }

        let routeValue = arguments[routeFlagIndex + 1]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard
            !routeValue.isEmpty,
            let url = URL(string: "swarpvouchers-demo://\(routeValue)"),
            let route = routeParser.route(for: url)
        else { return }

        apply(route: route)
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
