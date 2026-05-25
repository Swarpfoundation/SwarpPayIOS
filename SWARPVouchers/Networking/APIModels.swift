import Foundation

struct UserSession: Identifiable, Codable, Hashable {
    let id: String
    let email: String
    let displayName: String
    let kyc: KycTierStatus
    let sessionHandle: String
}

enum VoucherCategory: String, Codable, CaseIterable, Hashable {
    case gaming
    case appStores
    case streaming
    case streamingMena
    case telecom
    case telecomMorocco
    case retail
    case moroccoRetail
    case travel
    case travelMobility
    case utilities
    case utilitiesMorocco

    var displayName: String {
        switch self {
        case .gaming: "Gaming"
        case .appStores: "App Stores"
        case .streaming: "Streaming"
        case .streamingMena: "Streaming / MENA"
        case .telecom: "Telecom"
        case .telecomMorocco: "Telecom Morocco"
        case .retail: "Retail"
        case .moroccoRetail: "Morocco Retail"
        case .travel: "Travel"
        case .travelMobility: "Travel / Mobility"
        case .utilities: "Utilities"
        case .utilitiesMorocco: "Utilities Morocco"
        }
    }

    var symbolName: String {
        switch self {
        case .gaming: "gamecontroller"
        case .appStores: "apps.iphone"
        case .streaming: "headphones"
        case .streamingMena: "play.tv"
        case .telecom: "phone"
        case .telecomMorocco: "antenna.radiowaves.left.and.right"
        case .retail: "bag"
        case .moroccoRetail: "cart"
        case .travel: "airplane"
        case .travelMobility: "car"
        case .utilities: "bolt"
        case .utilitiesMorocco: "bolt"
        }
    }
}

enum VoucherAccent: String, Codable, Hashable {
    case emerald
    case blue
    case orange
    case amber
    case cyan
}

struct VoucherProduct: Identifiable, Codable, Hashable {
    let id: String
    let brand: String
    let shortBrand: String
    let category: VoucherCategory
    let range: String
    let defaultAmountMinor: Int
    let currency: String
    let status: String
    let delivery: String
    let tier: String
    let symbolName: String
    let logoText: String
    let accent: VoucherAccent
    let notes: String
    let denominationsMinor: [Int]
    var denominationLabels: [String]? = nil

    var title: String { brand }
    var chip: String { primaryDenominationLabel }
    var formattedAmount: String { "\(defaultAmountMinor / 100) \(currency)" }
    var available: Bool { status == "In stock" }
    var deliveryEstimate: String { delivery }
    var amountMinor: Int { defaultAmountMinor }
    var primaryDenominationLabel: String {
        denominationLabel(for: defaultAmountMinor)
    }

    func denominationLabel(for amountMinor: Int) -> String {
        if let denominationLabels,
           let index = denominationsMinor.firstIndex(of: amountMinor),
           denominationLabels.indices.contains(index) {
            return denominationLabels[index]
        }
        return "MAD \(amountMinor / 100)"
    }

    func denominationParts(for amountMinor: Int) -> (title: String, subtitle: String?) {
        let label = denominationLabel(for: amountMinor)
        if label.hasPrefix("MAD ") {
            return (String(label.dropFirst(4)), "MAD")
        }
        return (label, nil)
    }

    var logoAssetName: String? {
        switch id {
        case "spotify-premium": "SpotifyLogo"
        case "playstation-store": "PlayStationLogo"
        case "orange-mobile": "OrangeLogo"
        case "amazon-gift-card": "AmazonLogo"
        case "steam-wallet": "SteamLogo"
        case "roblox-gift-card": "RobloxLogo"
        case "riot-games": "RiotGamesLogo"
        case "ea-gift-card": "EALogo"
        case "battle-net-balance": "BattleNetLogo"
        case "apple-gift-card": "AppleLogo"
        case "google-play": "GooglePlayLogo"
        case "netflix-gift-card": "NetflixLogo"
        case "deezer-premium": "DeezerLogo"
        case "carrefour-gift-card": "CarrefourLogo"
        case "ikea-gift-card": "IkeaLogo"
        case "airbnb-gift-card": "AirbnbLogo"
        case "uber-gift-card": "UberLogo"
        case "hotels-gift-card": "HotelsLogo"
        default: nil
        }
    }
}

struct KycTierStatus: Codable, Hashable {
    let tier: String
    let status: String
    let dailyLimitMinor: Int
    let monthlyLimitMinor: Int
    let usedTodayMinor: Int
    let usedMonthMinor: Int

    var dailyRemainingMinor: Int { max(0, dailyLimitMinor - usedTodayMinor) }
    var formattedDailyRemaining: String { "\(dailyRemainingMinor / 100) MAD" }
}

struct VoucherOrder: Identifiable, Codable, Hashable {
    let id: String
    let productId: String
    let productTitle: String
    let amountMinor: Int
    let currency: String
    let status: String
    let date: String
    let category: VoucherCategory
    let receiptId: String?

    var deliveryStatus: String { status == "Delivered" ? "Receipt available" : "Digital delivery" }
    var formattedAmount: String { "\(amountMinor / 100) \(currency)" }
}

struct PaymentWidgetState: Codable, Hashable {
    let product: VoucherProduct
    let denominationMinor: Int
    let kyc: KycTierStatus
    let serviceFeeMinor: Int
    let paymentMethodLabel: String

    var subtotalMinor: Int { denominationMinor }
    var totalMinor: Int { denominationMinor + serviceFeeMinor }
}

struct Receipt: Identifiable, Codable, Hashable {
    let id: String
    let reference: String
    let productId: String
    let productTitle: String
    let amountMinor: Int
    let currency: String
    let status: String
    let issuedAt: String
}

struct SupportTicketDraft: Codable, Hashable {
    var category: String
    var reference: String
    var message: String
}

struct ClaimPreview: Codable, Hashable {
    let reference: String
    let productId: String
    let productTitle: String
    let amountMinor: Int
    let currency: String
    let status: String
    let recipientHint: String
}

struct DashboardMetric: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    let value: String
    let detail: String
}

struct SafeUIError: LocalizedError, Hashable {
    let title: String
    let message: String

    var errorDescription: String? { title }

    static let unavailable = SafeUIError(
        title: "Service unavailable",
        message: "The app could not load this state. Please try again."
    )

    static let invalidResponse = SafeUIError(
        title: "Invalid response",
        message: "The app could not safely read this response."
    )
}
