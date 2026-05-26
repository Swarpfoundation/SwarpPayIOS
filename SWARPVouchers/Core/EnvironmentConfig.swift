import Foundation

enum BuildMode: String {
    case debug
    case release
}

struct FeatureAvailability {
    let checkoutEnabled: Bool
    let voucherClaimEnabled: Bool
    let receiptIssuingEnabled: Bool
    let supportSubmissionEnabled: Bool
    let demoAuthEnabled: Bool
    let demoFixturesEnabled: Bool
    let localHTTPAllowed: Bool
    let customDemoSchemeAllowed: Bool

    static let internalDemo = FeatureAvailability(
        checkoutEnabled: true,
        voucherClaimEnabled: true,
        receiptIssuingEnabled: true,
        supportSubmissionEnabled: true,
        demoAuthEnabled: true,
        demoFixturesEnabled: true,
        localHTTPAllowed: true,
        customDemoSchemeAllowed: true
    )

    static let releaseLocked = FeatureAvailability(
        checkoutEnabled: false,
        voucherClaimEnabled: false,
        receiptIssuingEnabled: false,
        supportSubmissionEnabled: false,
        demoAuthEnabled: false,
        demoFixturesEnabled: false,
        localHTTPAllowed: false,
        customDemoSchemeAllowed: false
    )
}

struct EnvironmentConfig {
    let apiBaseURL: URL
}

enum SecurityPolicy {
    static func acceptsAPIBaseURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }
        #if DEBUG
        return scheme == "https" || scheme == "http"
        #else
        return scheme == "https"
        #endif
    }
}

struct AppEnvironment {
    let buildMode: BuildMode
    let features: FeatureAvailability
    let api: APIClient

    static let current = AppEnvironment()

    init() {
        #if DEBUG
        self.buildMode = .debug
        self.features = .internalDemo
        self.api = DemoAPIClient()
        #else
        self.buildMode = .release
        self.features = .releaseLocked
        self.api = NoBackendAPIClient()
        #endif
    }

    #if DEBUG
    static var debugAPIConfig: EnvironmentConfig {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "127.0.0.1"
        components.port = 3000
        return EnvironmentConfig(apiBaseURL: components.url!)
    }
    #endif
}

enum InternalDemoData {
    static var products: [VoucherProduct] {
        #if DEBUG
        return DemoFixtures.products
        #else
        return []
        #endif
    }

    static var orders: [VoucherOrder] {
        #if DEBUG
        return DemoFixtures.orders
        #else
        return []
        #endif
    }

    static var receipts: [Receipt] {
        #if DEBUG
        return DemoFixtures.receipts
        #else
        return []
        #endif
    }

    static func product(id: String) -> VoucherProduct? {
        #if DEBUG
        return DemoFixtures.product(id: id)
        #else
        return nil
        #endif
    }

    static func product(for order: VoucherOrder) -> VoucherProduct? {
        product(id: order.productId)
    }

    static func receipt(id: String) -> Receipt? {
        #if DEBUG
        return DemoFixtures.receipt(id: id)
        #else
        return nil
        #endif
    }

    static func session() -> UserSession? {
        #if DEBUG
        return DemoFixtures.session(email: "debug-user@swarppay.invalid")
        #else
        return nil
        #endif
    }

    static func claimPreview(reference: String) -> ClaimPreview? {
        #if DEBUG
        return DemoFixtures.claimPreview(reference: reference)
        #else
        return nil
        #endif
    }
}
