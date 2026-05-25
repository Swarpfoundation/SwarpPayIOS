import Foundation

final class DemoAPIClient: APIClient {
    func login(email: String, password: String) async throws -> UserSession {
        DemoFixtures.session(email: email)
    }

    func register(email: String, name: String) async throws -> UserSession {
        DemoFixtures.session(email: email, name: name)
    }

    func catalog() async throws -> [VoucherProduct] {
        DemoFixtures.products
    }

    func orders() async throws -> [VoucherOrder] {
        DemoFixtures.orders
    }

    func receipt(id: String) async throws -> Receipt {
        DemoFixtures.receipts.first { $0.id == id } ?? DemoFixtures.receipts[0]
    }

    func claimPreview(linkValue: String) async throws -> ClaimPreview {
        DemoFixtures.claimPreview(reference: linkValue)
    }

    func submitSupport(_ draft: SupportTicketDraft) async throws -> String {
        "SUP-\(abs(draft.message.hashValue) % 10000)"
    }

    func metrics() async throws -> [DashboardMetric] {
        []
    }
}

enum DemoFixtures {
    static func session(email: String, name: String = "Eddine") -> UserSession {
        UserSession(
            id: "consumer-eddine",
            email: email,
            displayName: name,
            kyc: KycTierStatus(
                tier: "Tier 2",
                status: "Approved",
                dailyLimitMinor: 500_000,
                monthlyLimitMinor: 3_000_000,
                usedTodayMinor: 125_000,
                usedMonthMinor: 460_000
            ),
            sessionHandle: "swarppay-session"
        )
    }

    private static func voucher(
        id: String,
        brand: String,
        shortBrand: String,
        category: VoucherCategory,
        range: String,
        defaultAmountMinor: Int,
        symbolName: String,
        logoText: String,
        accent: VoucherAccent,
        denominationsMinor: [Int],
        denominationLabels: [String]? = nil,
        tier: String = "Tier 1 / Tier 2",
        notes: String
    ) -> VoucherProduct {
        VoucherProduct(
            id: id,
            brand: brand,
            shortBrand: shortBrand,
            category: category,
            range: range,
            defaultAmountMinor: defaultAmountMinor,
            currency: "MAD",
            status: "In stock",
            delivery: "Digital delivery",
            tier: tier,
            symbolName: symbolName,
            logoText: logoText,
            accent: accent,
            notes: notes,
            denominationsMinor: denominationsMinor,
            denominationLabels: denominationLabels
        )
    }

    static let products: [VoucherProduct] = [
        voucher(id: "playstation-store", brand: "PlayStation Store", shortBrand: "PlayStation", category: .gaming, range: "100-1,000 MAD", defaultAmountMinor: 10_000, symbolName: "gamecontroller", logoText: "PS", accent: .blue, denominationsMinor: [10_000, 25_000, 50_000, 100_000], tier: "Tier 2", notes: "Use on eligible PlayStation Store purchases. Region restrictions may apply before redemption."),
        voucher(id: "xbox-gift-card", brand: "Xbox Gift Card", shortBrand: "Xbox", category: .gaming, range: "100-1,000 MAD", defaultAmountMinor: 10_000, symbolName: "xbox.logo", logoText: "XB", accent: .emerald, denominationsMinor: [10_000, 25_000, 50_000, 100_000], tier: "Tier 2", notes: "Digital Xbox credit for eligible games, subscriptions, and entertainment purchases."),
        voucher(id: "steam-wallet", brand: "Steam Wallet", shortBrand: "Steam", category: .gaming, range: "50-500 MAD", defaultAmountMinor: 10_000, symbolName: "gamecontroller.fill", logoText: "ST", accent: .blue, denominationsMinor: [5_000, 10_000, 25_000, 50_000], notes: "Add digital Steam credit to an eligible account after purchase confirmation."),
        voucher(id: "nintendo-eshop", brand: "Nintendo eShop", shortBrand: "Nintendo", category: .gaming, range: "100-500 MAD", defaultAmountMinor: 10_000, symbolName: "gamecontroller", logoText: "N", accent: .orange, denominationsMinor: [10_000, 25_000, 50_000], tier: "Tier 2", notes: "Digital Nintendo eShop credit for eligible game and content purchases."),
        voucher(id: "roblox-gift-card", brand: "Roblox Gift Card", shortBrand: "Roblox", category: .gaming, range: "50-500 MAD", defaultAmountMinor: 5_000, symbolName: "square.diamond.fill", logoText: "R", accent: .cyan, denominationsMinor: [5_000, 10_000, 20_000, 50_000], notes: "Digital Roblox credit delivered after purchase confirmation."),
        voucher(id: "razer-gold", brand: "Razer Gold", shortBrand: "Razer", category: .gaming, range: "50-500 MAD", defaultAmountMinor: 10_000, symbolName: "bolt.circle.fill", logoText: "RG", accent: .emerald, denominationsMinor: [5_000, 10_000, 25_000, 50_000], notes: "Digital gaming voucher for eligible Razer Gold purchases."),
        voucher(id: "riot-games", brand: "Riot Games / League of Legends", shortBrand: "Riot", category: .gaming, range: "50-500 MAD", defaultAmountMinor: 10_000, symbolName: "flame.fill", logoText: "R", accent: .amber, denominationsMinor: [5_000, 10_000, 25_000, 50_000], notes: "Digital Riot Games voucher for eligible League of Legends content."),
        voucher(id: "ea-gift-card", brand: "EA Gift Card", shortBrand: "EA", category: .gaming, range: "100-500 MAD", defaultAmountMinor: 10_000, symbolName: "sportscourt.fill", logoText: "EA", accent: .blue, denominationsMinor: [10_000, 25_000, 50_000], tier: "Tier 2", notes: "Digital EA credit for eligible game and entertainment purchases."),
        voucher(id: "battle-net-balance", brand: "Battle.net Balance", shortBrand: "Battle.net", category: .gaming, range: "100-500 MAD", defaultAmountMinor: 10_000, symbolName: "sparkles", logoText: "BN", accent: .blue, denominationsMinor: [10_000, 25_000, 50_000], tier: "Tier 2", notes: "Digital Battle.net balance for eligible game purchases and account content."),
        voucher(id: "apple-gift-card", brand: "Apple Gift Card", shortBrand: "Apple", category: .appStores, range: "100-1,000 MAD", defaultAmountMinor: 10_000, symbolName: "apple.logo", logoText: "A", accent: .cyan, denominationsMinor: [10_000, 25_000, 50_000, 100_000], tier: "Tier 2", notes: "Digital Apple credit for eligible App Store, media, and Apple services purchases."),
        voucher(id: "google-play", brand: "Google Play", shortBrand: "Google Play", category: .appStores, range: "50-500 MAD", defaultAmountMinor: 10_000, symbolName: "play.fill", logoText: "GP", accent: .emerald, denominationsMinor: [5_000, 10_000, 25_000, 50_000], notes: "Digital Google Play credit for eligible apps, games, and media purchases."),
        voucher(id: "netflix-gift-card", brand: "Netflix Gift Card", shortBrand: "Netflix", category: .streaming, range: "100-500 MAD", defaultAmountMinor: 10_000, symbolName: "play.rectangle.fill", logoText: "N", accent: .orange, denominationsMinor: [10_000, 25_000, 50_000], tier: "Tier 2", notes: "Digital Netflix voucher for eligible streaming account payments."),
        voucher(id: "spotify-premium", brand: "Spotify Premium", shortBrand: "Spotify", category: .streaming, range: "1-6 months", defaultAmountMinor: 5_000, symbolName: "headphones", logoText: "S", accent: .emerald, denominationsMinor: [5_000, 12_000, 22_000], denominationLabels: ["1 month", "3 months", "6 months"], notes: "Redeem through your Spotify account. Voucher value is delivered digitally after purchase confirmation."),
        voucher(id: "deezer-premium", brand: "Deezer Premium", shortBrand: "Deezer", category: .streaming, range: "1-6 months", defaultAmountMinor: 5_000, symbolName: "music.note", logoText: "D", accent: .cyan, denominationsMinor: [5_000, 12_000, 22_000], denominationLabels: ["1 month", "3 months", "6 months"], notes: "Digital Deezer Premium voucher delivered after purchase confirmation."),
        voucher(id: "anghami-plus", brand: "Anghami Plus", shortBrand: "Anghami", category: .streamingMena, range: "1-12 months", defaultAmountMinor: 4_000, symbolName: "waveform", logoText: "AN", accent: .blue, denominationsMinor: [4_000, 10_000, 30_000], denominationLabels: ["1 month", "3 months", "12 months"], notes: "Digital Anghami Plus voucher for eligible music streaming access."),
        voucher(id: "shahid-vip-voucher", brand: "Shahid VIP Voucher", shortBrand: "Shahid", category: .streamingMena, range: "1-12 months", defaultAmountMinor: 6_000, symbolName: "play.tv.fill", logoText: "SH", accent: .amber, denominationsMinor: [6_000, 15_000, 45_000], denominationLabels: ["1 month", "3 months", "12 months"], notes: "Digital Shahid VIP voucher for eligible MENA streaming access."),
        voucher(id: "osn-plus-voucher", brand: "OSN+ Voucher", shortBrand: "OSN+", category: .streamingMena, range: "1-12 months", defaultAmountMinor: 7_000, symbolName: "tv.fill", logoText: "OSN", accent: .cyan, denominationsMinor: [7_000, 18_000, 60_000], denominationLabels: ["1 month", "3 months", "12 months"], notes: "Digital OSN+ voucher for eligible entertainment streaming access."),
        voucher(id: "maroc-telecom-recharge", brand: "Maroc Telecom Recharge", shortBrand: "IAM", category: .telecomMorocco, range: "10-200 MAD", defaultAmountMinor: 5_000, symbolName: "antenna.radiowaves.left.and.right", logoText: "IAM", accent: .blue, denominationsMinor: [1_000, 2_000, 5_000, 10_000, 20_000], tier: "Tier 1", notes: "Digital recharge voucher for eligible Maroc Telecom mobile services."),
        voucher(id: "orange-mobile", brand: "Orange Mobile Recharge", shortBrand: "Orange", category: .telecomMorocco, range: "10-200 MAD", defaultAmountMinor: 5_000, symbolName: "iphone.gen2", logoText: "or", accent: .orange, denominationsMinor: [1_000, 2_000, 5_000, 10_000, 20_000], tier: "Tier 1", notes: "Mobile recharge voucher. Check phone number and operator eligibility before redemption."),
        voucher(id: "inwi-recharge", brand: "inwi Recharge", shortBrand: "inwi", category: .telecomMorocco, range: "5-200 MAD", defaultAmountMinor: 2_000, symbolName: "phone.fill", logoText: "in", accent: .cyan, denominationsMinor: [500, 2_000, 5_000, 10_000, 20_000], tier: "Tier 1", notes: "Digital recharge voucher for eligible inwi mobile services."),
        voucher(id: "amazon-gift-card", brand: "Amazon Gift Card", shortBrand: "Amazon", category: .retail, range: "100-1,000 MAD", defaultAmountMinor: 10_000, symbolName: "gift", logoText: "a", accent: .amber, denominationsMinor: [10_000, 25_000, 50_000, 100_000], tier: "Tier 2", notes: "Redeem into an eligible Amazon account. Marketplace and currency availability may vary."),
        voucher(id: "carrefour-gift-card", brand: "Carrefour Gift Card", shortBrand: "Carrefour", category: .retail, range: "100-500 MAD", defaultAmountMinor: 10_000, symbolName: "cart.fill", logoText: "C", accent: .blue, denominationsMinor: [10_000, 25_000, 50_000], notes: "Digital Carrefour gift card for eligible retail purchases."),
        voucher(id: "ikea-gift-card", brand: "IKEA Gift Card", shortBrand: "IKEA", category: .retail, range: "100-1,000 MAD", defaultAmountMinor: 10_000, symbolName: "house.fill", logoText: "IKEA", accent: .blue, denominationsMinor: [10_000, 25_000, 50_000, 100_000], tier: "Tier 2", notes: "Digital IKEA gift card for eligible home and retail purchases."),
        voucher(id: "hm-gift-card", brand: "H&M Gift Card", shortBrand: "H&M", category: .retail, range: "100-500 MAD", defaultAmountMinor: 10_000, symbolName: "tshirt.fill", logoText: "HM", accent: .orange, denominationsMinor: [10_000, 25_000, 50_000], notes: "Digital H&M gift card for eligible fashion purchases."),
        voucher(id: "decathlon-gift-card", brand: "Decathlon Gift Card", shortBrand: "Decathlon", category: .retail, range: "100-500 MAD", defaultAmountMinor: 10_000, symbolName: "figure.run", logoText: "D", accent: .blue, denominationsMinor: [10_000, 25_000, 50_000], notes: "Digital Decathlon gift card for eligible sports and outdoor purchases."),
        voucher(id: "jumia-morocco", brand: "Jumia Morocco", shortBrand: "Jumia", category: .moroccoRetail, range: "50-500 MAD", defaultAmountMinor: 10_000, symbolName: "shippingbox.fill", logoText: "J", accent: .orange, denominationsMinor: [5_000, 10_000, 25_000, 50_000], notes: "Digital Jumia Morocco voucher for eligible marketplace purchases."),
        voucher(id: "airbnb-gift-card", brand: "Airbnb Gift Card", shortBrand: "Airbnb", category: .travel, range: "250-1,000 MAD", defaultAmountMinor: 25_000, symbolName: "house.lodge.fill", logoText: "AB", accent: .orange, denominationsMinor: [25_000, 50_000, 100_000], tier: "Tier 2", notes: "Digital Airbnb gift card for eligible travel and stay purchases."),
        voucher(id: "uber-gift-card", brand: "Uber Gift Card", shortBrand: "Uber", category: .travelMobility, range: "100-500 MAD", defaultAmountMinor: 10_000, symbolName: "car.fill", logoText: "U", accent: .cyan, denominationsMinor: [10_000, 25_000, 50_000], notes: "Digital Uber voucher for eligible rides and meal delivery purchases."),
        voucher(id: "hotels-gift-card", brand: "Hotels.com Gift Card", shortBrand: "Hotels.com", category: .travel, range: "250-1,000 MAD", defaultAmountMinor: 25_000, symbolName: "bed.double.fill", logoText: "H", accent: .blue, denominationsMinor: [25_000, 50_000, 100_000], tier: "Tier 2", notes: "Digital Hotels.com gift card for eligible travel bookings."),
        voucher(id: "onee-bill-credit", brand: "ONEE Bill Credit", shortBrand: "ONEE", category: .utilitiesMorocco, range: "50-750 MAD", defaultAmountMinor: 15_000, symbolName: "bolt.fill", logoText: "ONEE", accent: .cyan, denominationsMinor: [5_000, 15_000, 30_000, 75_000], tier: "Tier 2", notes: "Digital utility bill credit for eligible ONEE bill payments."),
        voucher(id: "srm-casablanca-settat-bill-pay", brand: "SRM Casablanca-Settat Bill Pay", shortBrand: "SRM", category: .utilitiesMorocco, range: "50-750 MAD", defaultAmountMinor: 15_000, symbolName: "building.2.fill", logoText: "SRM", accent: .blue, denominationsMinor: [5_000, 15_000, 30_000, 75_000], tier: "Tier 2", notes: "Digital bill payment voucher for eligible Casablanca-Settat utility services."),
        voucher(id: "redal-bill-pay", brand: "Redal Bill Pay", shortBrand: "Redal", category: .utilitiesMorocco, range: "50-750 MAD", defaultAmountMinor: 15_000, symbolName: "drop.fill", logoText: "RD", accent: .cyan, denominationsMinor: [5_000, 15_000, 30_000, 75_000], tier: "Tier 2", notes: "Digital bill payment voucher for eligible Redal utility services.")
    ]

    static let orders: [VoucherOrder] = [
        VoucherOrder(id: "SPAY-2026-0522-8174", productId: "spotify-premium", productTitle: "Spotify Premium", amountMinor: 5_000, currency: "MAD", status: "Delivered", date: "22 May 2026, 8:14 PM", category: .streaming, receiptId: "receipt-spotify-premium"),
        VoucherOrder(id: "SPAY-2026-0521-6842", productId: "netflix-gift-card", productTitle: "Netflix Gift Card", amountMinor: 10_000, currency: "MAD", status: "Delivered", date: "21 May 2026, 7:02 PM", category: .streaming, receiptId: "receipt-netflix-gift-card"),
        VoucherOrder(id: "SPAY-2026-0520-4506", productId: "orange-mobile", productTitle: "Orange Mobile Recharge", amountMinor: 5_000, currency: "MAD", status: "Delivered", date: "20 May 2026, 6:33 PM", category: .telecomMorocco, receiptId: "receipt-orange-mobile"),
        VoucherOrder(id: "SPAY-2026-0518-9908", productId: "playstation-store", productTitle: "PlayStation Store", amountMinor: 25_000, currency: "MAD", status: "Active", date: "18 May 2026, 11:09 AM", category: .gaming, receiptId: nil),
        VoucherOrder(id: "SPAY-2026-0516-3124", productId: "steam-wallet", productTitle: "Steam Wallet", amountMinor: 10_000, currency: "MAD", status: "Delivered", date: "16 May 2026, 2:18 PM", category: .gaming, receiptId: "receipt-steam-wallet"),
        VoucherOrder(id: "SPAY-2026-0515-2261", productId: "amazon-gift-card", productTitle: "Amazon Gift Card", amountMinor: 10_000, currency: "MAD", status: "Delivered", date: "15 May 2026, 9:22 AM", category: .retail, receiptId: "receipt-amazon-gift-card")
    ]

    static let receipts: [Receipt] = products.enumerated().map { index, product in
        Receipt(
            id: "receipt-\(product.id)",
            reference: "SPAY-2026-0522-\(8100 + index)",
            productId: product.id,
            productTitle: product.brand,
            amountMinor: product.defaultAmountMinor,
            currency: product.currency,
            status: "Delivered",
            issuedAt: "22 May 2026, 8:\(String(format: "%02d", 10 + (index % 45))) PM"
        )
    }

    static func product(id: String) -> VoucherProduct {
        products.first { $0.id == id } ?? products[0]
    }

    static func receipt(id: String) -> Receipt {
        receipts.first { $0.id == id } ?? receipts[0]
    }

    static func order(for receipt: Receipt) -> VoucherOrder {
        orders.first { $0.receiptId == receipt.id } ?? orders[0]
    }

    static func claimPreview(reference: String) -> ClaimPreview {
        ClaimPreview(
            reference: "SPAY-8K72-MAD",
            productId: "spotify-premium",
            productTitle: "Spotify Premium",
            amountMinor: 10_000,
            currency: "MAD",
            status: "Ready to claim",
            recipientHint: "Eddine"
        )
    }
}
