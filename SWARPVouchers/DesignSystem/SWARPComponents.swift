import SwiftUI
import UIKit

enum AppTab: String, CaseIterable, Hashable {
    case home
    case catalog
    case vouchers
    case support
    case profile

    var title: String {
        switch self {
        case .home: "Home"
        case .catalog: "Catalog"
        case .vouchers: "Vouchers"
        case .support: "Support"
        case .profile: "Profile"
        }
    }

    static var primaryTabs: [AppTab] {
        [.home, .catalog, .vouchers, .support]
    }

    var symbolName: String {
        switch self {
        case .home: "house.fill"
        case .catalog: "ticket.fill"
        case .vouchers: "rectangle.stack.fill"
        case .support: "headphones"
        case .profile: "person.fill"
        }
    }
}

enum Haptics {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func lightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

struct LogoMark: View {
    var size: CGFloat = 64
    var glow = false
    var accessibilityLabel = "Swarp logo"

    var body: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: glow ? SWARPColor.signal.opacity(0.40) : .clear, radius: glow ? 26 : 0, x: 0, y: 0)
            .accessibilityLabel(accessibilityLabel)
    }
}

struct SwarpWordmark: View {
    var markSize: CGFloat = 34
    var textSize: CGFloat = 23

    var body: some View {
        HStack(spacing: 10) {
            LogoMark(size: markSize, glow: true)
            VStack(alignment: .leading, spacing: 4) {
                Text("SwarpPay")
                    .font(.system(size: textSize, weight: .semibold, design: .serif))
                    .tracking(-0.6)
                    .foregroundStyle(SWARPColor.cream)
                Rectangle()
                    .fill(LinearGradient(colors: [SWARPColor.signal.opacity(0.70), .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 66, height: 1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("SwarpPay")
    }
}

struct PremiumBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    LinearGradient(
                        colors: [SWARPColor.deepest, SWARPColor.primaryDark, SWARPColor.ink],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    RadialGradient(
                        colors: [SWARPColor.electricBlue.opacity(0.24), .clear],
                        center: UnitPoint(x: 0.18, y: 0.02),
                        startRadius: 4,
                        endRadius: 280
                    )
                    RadialGradient(
                        colors: [SWARPColor.signal.opacity(0.12), .clear],
                        center: UnitPoint(x: 0.88, y: 0.06),
                        startRadius: 6,
                        endRadius: 240
                    )
                    LinearGradient(
                        colors: [.white.opacity(0.045), .clear, .black.opacity(0.28)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    LinearGradient(
                        colors: [.clear, SWARPColor.panel.opacity(0.32)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .ignoresSafeArea()
            )
    }
}

extension View {
    func premiumBackground() -> some View { modifier(PremiumBackground()) }

    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        padding(SWARPSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(SWARPColor.cream.opacity(0.045))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(.white.opacity(0.10), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.28), radius: 22, x: 0, y: 14)
            )
    }
}

struct IconCircleButton: View {
    let symbolName: String
    var accessibilityLabel: String?
    var action: () -> Void = {}

    private var label: String {
        accessibilityLabel ?? symbolName
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "fill", with: "")
            .capitalized
    }

    var body: some View {
        Button {
            Haptics.lightImpact()
            action()
        } label: {
            BrandedIcon(symbolName: symbolName, size: 38, shape: .circle)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(label)
    }
}

enum BrandedIconShape {
    case circle
    case roundedSquare
}

struct BrandedIcon: View {
    let symbolName: String
    var size: CGFloat = 42
    var accent: Color = SWARPColor.signal
    var shape: BrandedIconShape = .roundedSquare

    var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: size * 0.43, weight: .semibold))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(accent)
            .frame(width: size, height: size)
            .background(
                Group {
                    if shape == .circle {
                        Circle()
                            .fill(LinearGradient(colors: [.white.opacity(0.06), accent.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    } else {
                        RoundedRectangle(cornerRadius: size * 0.34, style: .continuous)
                            .fill(LinearGradient(colors: [.white.opacity(0.07), accent.opacity(0.09)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
            )
            .overlay(
                Group {
                    if shape == .circle {
                        Circle().stroke(.white.opacity(0.11), lineWidth: 1)
                    } else {
                        RoundedRectangle(cornerRadius: size * 0.34, style: .continuous)
                            .stroke(accent.opacity(0.18), lineWidth: 1)
                    }
                }
            )
            .shadow(color: accent.opacity(0.12), radius: 16, x: 0, y: 10)
    }
}

struct SurfaceCard<Content: View>: View {
    var padding: CGFloat = SWARPSpacing.md
    var cornerRadius: CGFloat = SWARPRadius.lg
    var prominence: SurfaceProminence = .standard
    let content: Content

    init(
        padding: CGFloat = SWARPSpacing.md,
        cornerRadius: CGFloat = SWARPRadius.lg,
        prominence: SurfaceProminence = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.prominence = prominence
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SWARPSpacing.sm) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(prominence.fill)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(prominence.stroke, lineWidth: 1)
                )
                .shadow(color: .black.opacity(prominence.shadowOpacity), radius: prominence.shadowRadius, x: 0, y: prominence.shadowY)
        )
    }
}

enum SurfaceProminence {
    case subtle
    case standard
    case elevated

    var fill: Color {
        switch self {
        case .subtle: SWARPColor.cream.opacity(0.032)
        case .standard: SWARPColor.cream.opacity(0.052)
        case .elevated: SWARPColor.elevatedPanel.opacity(0.72)
        }
    }

    var stroke: Color {
        switch self {
        case .subtle: .white.opacity(0.07)
        case .standard: .white.opacity(0.10)
        case .elevated: SWARPColor.signal.opacity(0.16)
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .subtle: 0.12
        case .standard: 0.20
        case .elevated: 0.28
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .subtle: 10
        case .standard: 18
        case .elevated: 28
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .subtle: 8
        case .standard: 12
        case .elevated: 18
        }
    }
}

struct StatusBadge: View {
    let title: String
    var tone: Color = SWARPColor.signal

    var body: some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(tone)
            .background(tone.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(tone.opacity(0.18), lineWidth: 1))
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(SWARPType.section)
                .foregroundStyle(SWARPColor.cream)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SWARPColor.signal.opacity(0.92))
            }
        }
        .padding(.top, SWARPSpacing.md)
    }
}

struct BrandOrb: View {
    let product: VoucherProduct
    var size: CGFloat = 62

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(product.cardGradient)
            LinearGradient(colors: [.white.opacity(0.16), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
            ProductLogoMark(product: product, size: size * 0.76)
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .stroke(.white.opacity(0.13), lineWidth: 1)
        )
        .shadow(color: product.glowColor.opacity(0.18), radius: 22, x: 0, y: 12)
    }
}

struct ProductLogoMark: View {
    let product: VoucherProduct
    var size: CGFloat
    var opacity: Double = 1

    var body: some View {
        Group {
            if let logoAssetName = product.logoAssetName {
                Image(logoAssetName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: product.symbolName)
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
        .opacity(opacity)
        .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 8)
    }
}

struct VerificationCard: View {
    let kyc: KycTierStatus
    @State private var animatedProgress = 0.0

    var body: some View {
        SurfaceCard(padding: 16) {
            HStack(spacing: 14) {
                BrandedIcon(symbolName: "shield.checkered", size: 58)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Tier 2 approved")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(SWARPColor.cream)
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(SWARPColor.signal)
                    }
                    Text("Daily limit: \(kyc.usedTodayMinor / 100) / \(kyc.dailyLimitMinor / 100) MAD")
                        .font(.caption)
                        .foregroundStyle(SWARPColor.coolGray)
                    ProgressBar(progress: animatedProgress)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x2563EB).opacity(0.18), SWARPColor.navyLift.opacity(0.42), .black.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 0.1)
        )
        .onAppear {
            withAnimation(SWARPMotion.enter.delay(0.12)) {
                animatedProgress = Double(kyc.usedTodayMinor) / Double(kyc.dailyLimitMinor)
            }
        }
    }
}

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.10))
                Capsule()
                    .fill(LinearGradient(colors: [SWARPColor.signal, SWARPColor.electricBlue], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(8, proxy.size.width * min(1, max(0, progress))))
                    .shadow(color: SWARPColor.signal.opacity(0.34), radius: 10, x: 0, y: 0)
            }
        }
        .frame(height: 7)
    }
}

struct QuickActionTile: View {
    let title: String
    let symbolName: String
    var detail: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: 12) {
                BrandedIcon(symbolName: symbolName, size: 44)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(SWARPColor.cream)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    if let detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(SWARPColor.coolGray)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 74, alignment: .leading)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: SWARPRadius.lg, style: .continuous)
                    .fill(LinearGradient(colors: [.white.opacity(0.07), .white.opacity(0.025)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(RoundedRectangle(cornerRadius: SWARPRadius.lg).stroke(.white.opacity(0.10), lineWidth: 1))
            )
        }
        .buttonStyle(PressableScale())
    }
}

struct VoucherMiniCard: View {
    let product: VoucherProduct
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(product.cardGradient)
                ProductLogoMark(product: product, size: 82, opacity: 0.88)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 16)
                LinearGradient(colors: [.clear, .black.opacity(0.74)], startPoint: .center, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 3) {
                    Text(product.shortBrand)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text("Starts at \(product.denominationLabel(for: product.denominationsMinor[0]))")
                        .font(.caption2)
                        .foregroundStyle(SWARPColor.coolGray)
                }
                .padding(11)
            }
            .frame(width: 112, height: 144)
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.12), lineWidth: 1))
            .shadow(color: product.glowColor.opacity(0.16), radius: 18, x: 0, y: 12)
        }
        .buttonStyle(PressableScale())
    }
}

struct PremiumVoucherCard: View {
    let product: VoucherProduct
    var amountMinor: Int?
    var compact = false
    var action: (() -> Void)?

    private var displayBrand: String {
        compact ? product.brand.replacingOccurrences(of: " ", with: "\n") : product.brand
    }

    var body: some View {
        Button(action: { action?() }) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(product.cardGradient)
                RadialGradient(colors: [.white.opacity(0.19), .clear], center: UnitPoint(x: 0.18, y: 0.18), startRadius: 4, endRadius: 150)
                LinearGradient(colors: [.white.opacity(0.12), .clear, SWARPColor.signal.opacity(0.07)], startPoint: .topLeading, endPoint: .bottomTrailing)
                ProductLogoMark(product: product, size: compact ? 178 : 204, opacity: 0.34)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.trailing, 10)
                    .padding(.top, 36)
                VStack(alignment: .leading, spacing: compact ? 14 : 20) {
                    HStack(alignment: .top) {
                        Spacer()
                        StatusBadge(title: product.status, tone: SWARPColor.success)
                    }
                    Spacer(minLength: compact ? 10 : 22)
                    Text(displayBrand)
                        .font(.system(size: compact ? 24 : 27, weight: .semibold))
                        .tracking(-0.8)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .frame(width: compact ? 175 : 220, alignment: .leading)
                    Text("\(product.category.displayName) voucher")
                        .font(.caption)
                        .foregroundStyle(SWARPColor.coolGray)
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(product.denominationLabel(for: amountMinor ?? product.defaultAmountMinor))
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundStyle(.white)
                                .background(SWARPColor.signal.opacity(0.11))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(SWARPColor.signal.opacity(0.22), lineWidth: 1))
                            Label(product.delivery, systemImage: "bolt.fill")
                                .font(.caption2)
                                .foregroundStyle(SWARPColor.coolGray)
                        }
                        Spacer()
                        Text("View")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 15)
                            .padding(.vertical, 9)
                            .foregroundStyle(.white)
                            .background(.white.opacity(0.10))
                            .clipShape(Capsule())
                    }
                }
                .padding(compact ? 16 : 20)
            }
            .frame(minHeight: compact ? 218 : 250)
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.11), lineWidth: 1))
            .shadow(color: product.glowColor.opacity(0.18), radius: 26, x: 0, y: 18)
        }
        .buttonStyle(PressableScale())
        .disabled(action == nil)
    }
}

struct CatalogProductRow: View {
    let product: VoucherProduct
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            SurfaceCard(padding: 10) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(product.cardGradient)
                        ProductLogoMark(product: product, size: 64, opacity: 0.95)
                    }
                    .frame(width: 88, height: 88)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.12), lineWidth: 1))
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(product.brand)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(SWARPColor.cream)
                                    .lineLimit(1)
                                Text(product.category.displayName)
                                    .font(.caption2)
                                    .foregroundStyle(SWARPColor.coolGray.opacity(0.75))
                            }
                            Spacer()
                            StatusBadge(title: product.status, tone: SWARPColor.success)
                        }
                        HStack {
                            Text(product.chip)
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .foregroundStyle(.white)
                                .background(SWARPColor.signal.opacity(0.09))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(SWARPColor.signal.opacity(0.20), lineWidth: 1))
                            Spacer()
                            Text("View")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .foregroundStyle(.white)
                                .background(LinearGradient.swarpPrimaryAction)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        Label(product.delivery, systemImage: "bolt.fill")
                            .font(.caption2)
                            .foregroundStyle(SWARPColor.coolGray.opacity(0.75))
                    }
                }
            }
        }
        .buttonStyle(PressableScale())
    }
}

struct DenominationButton: View {
    let amountMinor: Int
    var label: String?
    let isSelected: Bool
    let action: () -> Void

    private var displayParts: (title: String, subtitle: String?) {
        guard let label else {
            return ("\(amountMinor / 100)", "MAD")
        }
        if label.hasPrefix("MAD ") {
            return (String(label.dropFirst(4)), "MAD")
        }
        return (label, nil)
    }

    var body: some View {
        Button {
            Haptics.selection()
            withAnimation(.spring(response: 0.24, dampingFraction: 0.80)) {
                action()
            }
        } label: {
            VStack(spacing: 4) {
                Text(displayParts.title)
                    .font(.system(size: displayParts.subtitle == nil ? 13 : 17, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
                if let subtitle = displayParts.subtitle {
                    Text(subtitle)
                        .font(.caption2.weight(.bold))
                        .tracking(1.4)
                        .foregroundStyle(SWARPColor.coolGray)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? SWARPColor.cream : SWARPColor.coolGray)
            .background(isSelected ? Color(hex: 0x2563EB).opacity(0.25) : .white.opacity(0.045))
            .scaleEffect(isSelected ? 1.03 : 1)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? SWARPColor.signal.opacity(0.42) : .white.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: isSelected ? SWARPColor.signal.opacity(0.12) : .clear, radius: 18, x: 0, y: 10)
            .animation(.spring(response: 0.24, dampingFraction: 0.80), value: isSelected)
        }
        .buttonStyle(PressableScale())
    }
}

struct InfoRow: View {
    let symbolName: String
    let label: String
    let value: String
    var showsChevron = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbolName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(SWARPColor.coolGray.opacity(0.65))
                .frame(width: 20)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SWARPColor.coolGray)
            Spacer()
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(SWARPColor.cream)
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SWARPColor.coolGray.opacity(0.5))
            }
        }
        .padding(.vertical, 11)
    }
}

struct PaymentMethodCard: View {
    var body: some View {
        SurfaceCard(padding: 14) {
            HStack(spacing: 12) {
                BrandedIcon(symbolName: "creditcard.fill", size: 50, accent: Color(hex: 0x3B82F6))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Visa •••• 4242")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SWARPColor.cream)
                    Text("Expires 12/26")
                        .font(.caption2)
                        .foregroundStyle(SWARPColor.coolGray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(SWARPColor.coolGray.opacity(0.55))
            }
        }
    }
}

struct PriceBreakdownCard: View {
    let subtotalMinor: Int
    let serviceFeeMinor: Int
    let currency: String

    var body: some View {
        SurfaceCard {
            PriceRow(label: "Subtotal", value: money(subtotalMinor, currency: currency))
            PriceRow(label: "Service fee", value: money(serviceFeeMinor, currency: currency))
            Rectangle().fill(.white.opacity(0.10)).frame(height: 1).padding(.vertical, 2)
            PriceRow(label: "Total", value: money(subtotalMinor + serviceFeeMinor, currency: currency), isTotal: true)
        }
    }

    private func money(_ minor: Int, currency: String) -> String {
        String(format: "%.2f %@", Double(minor) / 100.0, currency)
    }
}

struct PriceRow: View {
    let label: String
    let value: String
    var isTotal = false

    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? .headline.weight(.semibold) : .subheadline)
                .foregroundStyle(isTotal ? SWARPColor.signal : SWARPColor.coolGray)
            Spacer()
            Text(value)
                .font(isTotal ? .headline.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundStyle(isTotal ? SWARPColor.signal : SWARPColor.cream)
        }
    }
}

struct CTAButton: View {
    let title: String
    var subtitle: String?
    var symbolName: String = "chevron.right"
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.lightImpact()
            action()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                Spacer()
                Image(systemName: symbolName)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(LinearGradient.swarpPrimaryAction)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: SWARPColor.electricBlue.opacity(0.32), radius: 22, x: 0, y: 16)
        }
        .buttonStyle(PressableScale())
    }
}

struct SupportOptionCard: View {
    let title: String
    let bodyText: String

    var body: some View {
        SurfaceCard {
            HStack(spacing: 12) {
                BrandedIcon(symbolName: "headphones", size: 46)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SWARPColor.cream)
                    Text(bodyText)
                        .font(.caption)
                        .foregroundStyle(SWARPColor.coolGray)
                        .lineLimit(3)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SWARPColor.coolGray.opacity(0.55))
            }
        }
    }
}

struct BottomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.primaryTabs, id: \.self) { tab in
                Button {
                    guard selectedTab != tab else { return }
                    Haptics.selection()
                    withAnimation(SWARPMotion.smooth) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbolName)
                            .font(.system(size: 17, weight: .semibold))
                            .scaleEffect(selectedTab == tab ? 1.08 : 1)
                        Text(tab.title)
                            .font(.system(size: 9.5, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .foregroundStyle(selectedTab == tab ? SWARPColor.signal : SWARPColor.coolGray.opacity(0.62))
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(selectedTab == tab ? SWARPColor.signal.opacity(0.10) : .clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(selectedTab == tab ? SWARPColor.signal.opacity(0.12) : .clear, lineWidth: 1)
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(PressableScale())
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(.black.opacity(0.62))
        .overlay(alignment: .top) {
            Rectangle().fill(.white.opacity(0.10)).frame(height: 1)
        }
    }
}

extension VoucherProduct {
    var cardGradient: LinearGradient {
        switch accent {
        case .emerald:
            LinearGradient(colors: [Color(hex: 0x34D399).opacity(0.42), Color(hex: 0x052E25).opacity(0.68), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .blue:
            LinearGradient(colors: [Color(hex: 0x60A5FA).opacity(0.45), Color(hex: 0x172554).opacity(0.66), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .orange:
            LinearGradient(colors: [Color(hex: 0xF97316).opacity(0.56), Color(hex: 0x431407).opacity(0.68), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .amber:
            LinearGradient(colors: [Color(hex: 0xFCD34D).opacity(0.32), Color(hex: 0x171717).opacity(0.70), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cyan:
            LinearGradient(colors: [SWARPColor.signal.opacity(0.38), SWARPColor.navyLift.opacity(0.70), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var glowColor: Color {
        switch accent {
        case .emerald: Color(hex: 0x10B981)
        case .blue: Color(hex: 0x3B82F6)
        case .orange: Color(hex: 0xF97316)
        case .amber: Color(hex: 0xF59E0B)
        case .cyan: SWARPColor.signal
        }
    }
}

struct DebugBuildLabel: View {
    var body: some View {
        #if DEBUG
        Text("Development build")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(SWARPColor.coolGray.opacity(0.55))
            .frame(maxWidth: .infinity, alignment: .center)
        #endif
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        CTAButton(title: title, action: action)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(SWARPColor.cream)
                .background(.white.opacity(0.02))
                .clipShape(RoundedRectangle(cornerRadius: SWARPRadius.md, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: SWARPRadius.md).stroke(SWARPColor.signal.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(PressableScale())
    }
}

struct InfoCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        SurfaceCard {
            content
        }
    }
}

struct MetricCard: View {
    let label: String
    let value: String
    let detail: String

    var body: some View {
        SurfaceCard {
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(SWARPColor.coolGray)
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(SWARPColor.cream)
            Text(detail)
                .font(.caption)
                .foregroundStyle(SWARPColor.coolGray)
        }
    }
}

struct KycLimitCard: View {
    let kyc: KycTierStatus

    var body: some View {
        VerificationCard(kyc: kyc)
    }
}

struct VoucherTile: View {
    let product: VoucherProduct

    var body: some View {
        CatalogProductRow(product: product) {}
    }
}

struct ScreenScaffold<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SWARPSpacing.lg) {
                Text(title)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(SWARPColor.cream)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(SWARPColor.coolGray)
                content
            }
            .padding(SWARPSpacing.md)
        }
        .premiumBackground()
    }
}
