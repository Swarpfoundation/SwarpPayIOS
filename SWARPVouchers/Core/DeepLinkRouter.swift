import Foundation

struct DeepLinkRouter {
    private let debugHosts = Set(["swarpvouchers.local", "swarppay.local", "127.0.0.1"])
    private let productionHosts = Set<String>()

    func route(for url: URL) -> AppRoute? {
        guard let scheme = url.scheme?.lowercased(), scheme == "https" else { return nil }
        guard let host = url.host?.lowercased(), allowedHosts.contains(host) else { return nil }

        let parts = routeParts(for: url)
        guard let first = parts.first else { return nil }

        switch first {
        case "onboarding":
            return .onboarding
        case "login":
            return .login
        case "register":
            return .register
        case "home":
            return .home
        case "catalog":
            return .catalog
        case "category" where parts.count >= 2:
            return categoryRoute(parts[1]).map { .category($0) }
        case "product" where parts.count >= 2:
            return .product(productId(parts[1]))
        case "checkout" where parts.count >= 2:
            return .checkout(productId(parts[1]))
        case "kyc":
            return .kyc
        case "orders", "vouchers", "my-vouchers":
            return .orders
        case "receipt" where parts.count >= 2 && AppEnvironment.current.features.receiptIssuingEnabled:
            return .receipt(demoReceiptId(parts[1]))
        case "profile":
            return .profile
        case "r" where parts.count >= 2:
            return .support("Referral \(redacted(parts[1]))")
        case "campaigns" where parts.count >= 2:
            return .support("Campaign \(safeSegment(parts[1]))")
        case "claim" where parts.count >= 2 && AppEnvironment.current.features.voucherClaimEnabled:
            return .claim(redacted(parts[1]))
        case "receipts" where parts.count >= 2 && AppEnvironment.current.features.receiptIssuingEnabled:
            return .receipt(redacted(parts[1]))
        case "support":
            return .support(parts.dropFirst().first.map { "Support \(redacted($0))" })
        default:
            return nil
        }
    }

    private var allowedHosts: Set<String> {
        #if DEBUG
        return debugHosts
        #else
        return productionHosts
        #endif
    }

    private func routeParts(for url: URL) -> [String] {
        let pathParts = url.pathComponents.filter { $0 != "/" }
        return pathParts
    }

    private func categoryRoute(_ value: String) -> VoucherCategory? {
        switch value {
        case "gaming": return .gaming
        case "streaming": return .streaming
        case "telecom": return .telecomMorocco
        case "retail": return .retail
        case "utility", "utilities": return .utilitiesMorocco
        default: return nil
        }
    }

    private func productId(_ value: String) -> String {
        switch value {
        case "spotify", "streaming": return "spotify-premium"
        case "playstation", "gaming": return "playstation-store"
        case "orange", "telecom": return "orange-mobile"
        case "amazon", "retail": return "amazon-gift-card"
        case "utility", "utilities": return "onee-bill-credit"
        default: return value
        }
    }

    private func demoReceiptId(_ value: String) -> String {
        switch value {
        case "spotify": return "receipt-spotify-premium"
        case "orange": return "receipt-orange-mobile"
        case "amazon": return "receipt-amazon-gift-card"
        case "demo": return "receipt-spotify-premium"
        default: return redacted(value)
        }
    }

    private func safeSegment(_ value: String) -> String {
        String(value.prefix(48))
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
    }

    private func redacted(_ value: String) -> String {
        let safe = safeSegment(value)
        guard safe.count > 8 else { return "link ending \(safe)" }
        return "link ending \(safe.suffix(4))"
    }
}
