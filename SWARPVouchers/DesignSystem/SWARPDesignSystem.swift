import SwiftUI

enum SWARPColor {
    static let signal = Color(hex: 0x35D7D6)
    static let electricBlue = Color(hex: 0x3B82F6)
    static let royalBlue = Color(hex: 0x1D4ED8)
    static let minted = Color(hex: 0x8CF5D2)
    static let gold = Color(hex: 0xF6C85F)
    static let primaryDark = Color(hex: 0x02091E)
    static let ink = Color(hex: 0x02040A)
    static let deepest = Color(hex: 0x010205)
    static let navyLift = Color(hex: 0x0A1A3A)
    static let panel = Color(hex: 0x071126)
    static let elevatedPanel = Color(hex: 0x0D1830)
    static let cream = Color(hex: 0xF5F7FA)
    static let coolGray = Color(hex: 0xA7B3C2)
    static let success = Color(hex: 0x55D68B)
    static let warning = Color(hex: 0xF6C85F)
    static let danger = Color(hex: 0xFF6B6B)
}

enum SWARPSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 44
}

enum SWARPType {
    static let eyebrow = Font.caption.bold()
    static let hero = Font.largeTitle.bold()
    static let title = Font.title.bold()
    static let section = Font.headline.bold()
    static let body = Font.body
    static let detail = Font.footnote
}

enum SWARPRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 22
    static let xl: CGFloat = 28
}

enum SWARPMotion {
    static let quick = Animation.spring(response: 0.22, dampingFraction: 0.82)
    static let smooth = Animation.spring(response: 0.36, dampingFraction: 0.84)
    static let enter = Animation.spring(response: 0.48, dampingFraction: 0.86)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    LinearGradient(
                        colors: [SWARPColor.deepest, SWARPColor.primaryDark, SWARPColor.ink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    RadialGradient(
                        colors: [SWARPColor.signal.opacity(0.16), .clear],
                        center: .topTrailing,
                        startRadius: 20,
                        endRadius: 380
                    )
                    LinearGradient(
                        colors: [.clear, SWARPColor.navyLift.opacity(0.22)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()
            )
    }
}

struct PressableScale: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .animation(SWARPMotion.quick, value: configuration.isPressed)
    }
}

extension ShapeStyle where Self == LinearGradient {
    static var swarpPanel: LinearGradient {
        LinearGradient(
            colors: [SWARPColor.elevatedPanel.opacity(0.96), SWARPColor.primaryDark.opacity(0.90)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var swarpPrimaryAction: LinearGradient {
        LinearGradient(
            colors: [SWARPColor.signal, SWARPColor.electricBlue, SWARPColor.royalBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func appBackground() -> some View { modifier(AppBackground()) }

    func premiumPanel(cornerRadius: CGFloat = SWARPRadius.md) -> some View {
        padding(SWARPSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.swarpPanel)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(SWARPColor.signal.opacity(0.16), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.24), radius: 18, x: 0, y: 10)
            )
    }
}

struct LimitProgress: View {
    let title: String
    let usedMinor: Int
    let limitMinor: Int
    let currency: String

    private var progress: Double {
        guard limitMinor > 0 else { return 0 }
        return min(1, Double(usedMinor) / Double(limitMinor))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SWARPSpacing.xs) {
            HStack {
                Text(title)
                    .font(SWARPType.detail.weight(.semibold))
                    .foregroundStyle(SWARPColor.coolGray)
                Spacer()
                Text("\(usedMinor / 100) / \(limitMinor / 100) \(currency)")
                    .font(SWARPType.detail)
                    .foregroundStyle(SWARPColor.coolGray)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(SWARPColor.cream.opacity(0.1))
                    Capsule()
                        .fill(SWARPColor.signal)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 8)
        }
    }
}

struct EmptyStateCard: View {
    let title: String
    let message: String

    var body: some View {
        InfoCard {
            Image(systemName: "tray")
                .font(.title2)
                .foregroundStyle(SWARPColor.signal)
            Text(title)
                .font(SWARPType.section)
                .foregroundStyle(SWARPColor.cream)
            Text(message)
                .font(SWARPType.detail)
                .foregroundStyle(SWARPColor.coolGray)
        }
    }
}

struct LoadingStateCard: View {
    let title: String

    var body: some View {
        InfoCard {
            HStack(spacing: SWARPSpacing.sm) {
                ProgressView()
                    .tint(SWARPColor.signal)
                Text(title)
                    .font(SWARPType.section)
                    .foregroundStyle(SWARPColor.cream)
            }
        }
    }
}

struct ErrorStateCard: View {
    let error: SafeUIError

    var body: some View {
        InfoCard {
            StatusBadge(title: error.title, tone: SWARPColor.warning)
            Text(error.message)
                .font(SWARPType.detail)
                .foregroundStyle(SWARPColor.coolGray)
        }
    }
}
