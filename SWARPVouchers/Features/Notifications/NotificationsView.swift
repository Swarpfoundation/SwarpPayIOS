import SwiftUI

enum NotificationTarget: Hashable {
    case route(AppRoute)
    case tab(AppTab)
}

struct SwarpNotification: Identifiable {
    let id: String
    let title: String
    let body: String
    let time: String
    let symbolName: String
    let tint: Color
    let isUnread: Bool
    let actionTitle: String
    let target: NotificationTarget

    static let mocks: [SwarpNotification] = [
        SwarpNotification(
            id: "claim-ready",
            title: "Voucher claimed",
            body: "Spotify Premium is ready in your vouchers.",
            time: "Just now",
            symbolName: "gift.fill",
            tint: SWARPColor.signal,
            isUnread: true,
            actionTitle: "Open claim",
            target: .route(.claim("SPAY-8K72-MAD"))
        ),
        SwarpNotification(
            id: "reward-credit",
            title: "Reward unlocked",
            body: "You got 10 MAD voucher credit after your latest claim.",
            time: "8 min ago",
            symbolName: "sparkles",
            tint: SWARPColor.gold,
            isUnread: true,
            actionTitle: "See vouchers",
            target: .tab(.vouchers)
        ),
        SwarpNotification(
            id: "steam-delivered",
            title: "Steam Wallet delivered",
            body: "Your 100 MAD Steam Wallet code and receipt are available.",
            time: "Today",
            symbolName: "checkmark.seal.fill",
            tint: SWARPColor.success,
            isUnread: false,
            actionTitle: "View receipt",
            target: .route(.receipt("receipt-steam-wallet"))
        ),
        SwarpNotification(
            id: "limit-update",
            title: "Tier 2 limit refreshed",
            body: "Your daily voucher limit is available again.",
            time: "Yesterday",
            symbolName: "shield.checkered",
            tint: Color(hex: 0x8CF5D2),
            isUnread: false,
            actionTitle: "View profile",
            target: .route(.profile)
        ),
        SwarpNotification(
            id: "support-reply",
            title: "Support replied",
            body: "We added an update to your voucher claim question.",
            time: "22 May",
            symbolName: "headphones",
            tint: Color(hex: 0x60A5FA),
            isUnread: false,
            actionTitle: "Open support",
            target: .route(.support("SPAY-2026-0522-8174"))
        )
    ]

    static var mockUnreadCount: Int {
        mocks.filter(\.isUnread).count
    }
}

struct NotificationBellButton: View {
    let unreadCount: Int
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.lightImpact()
            action()
        } label: {
            ZStack(alignment: .topTrailing) {
                BrandedIcon(symbolName: "bell", size: 38, shape: .circle)
                if unreadCount > 0 {
                    Text("\(min(unreadCount, 9))")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(SWARPColor.deepest)
                        .frame(width: 16, height: 16)
                        .background(SWARPColor.gold)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(SWARPColor.deepest.opacity(0.72), lineWidth: 1))
                        .offset(x: 2, y: -2)
                }
            }
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(unreadCount > 0 ? "Notifications, \(unreadCount) unread" : "Notifications")
    }
}

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    let notifications: [SwarpNotification]
    let onSelect: (SwarpNotification) -> Void

    private var unreadCount: Int {
        notifications.filter(\.isUnread).count
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [SWARPColor.primaryDark, SWARPColor.deepest],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: SWARPSpacing.md) {
                header

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(notifications) { notification in
                            NotificationRow(notification: notification) {
                                onSelect(notification)
                            }
                        }
                    }
                    .padding(.bottom, SWARPSpacing.lg)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, SWARPSpacing.md)
            .padding(.top, SWARPSpacing.md)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: SWARPSpacing.md) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Notifications")
                    .font(.title2.bold())
                    .foregroundStyle(SWARPColor.cream)
                Text(unreadCount == 1 ? "1 unread update" : "\(unreadCount) unread updates")
                    .font(.subheadline)
                    .foregroundStyle(SWARPColor.coolGray)
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                BrandedIcon(symbolName: "xmark", size: 36, shape: .circle)
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("Close notifications")
        }
    }
}

private struct NotificationRow: View {
    let notification: SwarpNotification
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    BrandedIcon(symbolName: notification.symbolName, size: 46, accent: notification.tint)
                    if notification.isUnread {
                        Circle()
                            .fill(SWARPColor.gold)
                            .frame(width: 9, height: 9)
                            .overlay(Circle().stroke(SWARPColor.deepest, lineWidth: 1))
                            .offset(x: 1, y: -1)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(notification.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SWARPColor.cream)
                            .lineLimit(2)
                        Spacer(minLength: SWARPSpacing.sm)
                        Text(notification.time)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(SWARPColor.coolGray.opacity(0.72))
                            .lineLimit(1)
                    }

                    Text(notification.body)
                        .font(.caption)
                        .foregroundStyle(SWARPColor.coolGray)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 6) {
                        Text(notification.actionTitle)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(notification.tint)
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(notification.tint.opacity(0.82))
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: SWARPRadius.lg, style: .continuous)
                    .fill(notification.isUnread ? SWARPColor.signal.opacity(0.08) : .white.opacity(0.045))
                    .overlay(
                        RoundedRectangle(cornerRadius: SWARPRadius.lg, style: .continuous)
                            .stroke(notification.isUnread ? SWARPColor.signal.opacity(0.18) : .white.opacity(0.09), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PressableScale())
        .accessibilityElement(children: .combine)
    }
}
