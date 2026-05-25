import SwiftUI

struct MyVouchersView: View {
    @EnvironmentObject private var appState: AppState
    @State private var filter: VoucherFilter = .active
    private let orders = DemoFixtures.orders

    private var visibleOrders: [VoucherOrder] {
        switch filter {
        case .active:
            orders.filter { $0.status == "Active" }
        case .delivered:
            orders.filter { $0.status == "Delivered" }
        case .receipts:
            orders.filter { $0.receiptId != nil }
        case .support:
            orders
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SWARPSpacing.md) {
            VStack(alignment: .leading, spacing: 6) {
                Text("My Vouchers")
                    .font(.system(size: 26, weight: .semibold))
                    .tracking(-0.9)
                    .foregroundStyle(SWARPColor.cream)
                Text("Your vouchers and receipts.")
                    .font(.subheadline)
                    .foregroundStyle(SWARPColor.coolGray.opacity(0.72))
            }

            VoucherSegmentedControl(selection: $filter)

            VStack(spacing: 12) {
                ForEach(visibleOrders) { order in
                    VoucherOrderCard(order: order) {
                        if let receiptId = order.receiptId {
                            appState.path.append(AppRoute.receipt(receiptId))
                        } else {
                            appState.selectedTab = .support
                        }
                    }
                }
            }
        }
    }
}

struct OrderStatusView: View {
    var body: some View {
        MyVouchersView()
    }
}

private enum VoucherFilter: String, CaseIterable {
    case active = "Active"
    case delivered = "Delivered"
    case receipts = "Receipts"
    case support = "Support"
}

private struct VoucherSegmentedControl: View {
    @Binding var selection: VoucherFilter

    var body: some View {
        HStack(spacing: 4) {
            ForEach(VoucherFilter.allCases, id: \.self) { item in
                Button {
                    selection = item
                } label: {
                    Text(item.rawValue)
                        .font(.caption.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .foregroundStyle(selection == item ? SWARPColor.cream : SWARPColor.coolGray.opacity(0.70))
                        .background(selection == item ? Color(hex: 0x2563EB).opacity(0.32) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                }
                .buttonStyle(PressableScale())
            }
        }
        .padding(4)
        .background(.white.opacity(0.045))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.10), lineWidth: 1))
    }
}

private struct VoucherOrderCard: View {
    let order: VoucherOrder
    let action: () -> Void

    private var product: VoucherProduct { DemoFixtures.product(id: order.productId) }

    var body: some View {
        Button(action: action) {
            SurfaceCard(padding: 10) {
                HStack(spacing: 12) {
                    BrandOrb(product: product)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(order.productTitle)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(SWARPColor.cream)
                                    .lineLimit(1)
                                Text("\(order.status) · \(order.date)")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(order.status == "Delivered" ? SWARPColor.success : SWARPColor.signal)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(order.formattedAmount)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(SWARPColor.cream)
                        }
                        HStack {
                            Label(order.receiptId == nil ? "Digital delivery" : "Receipt available", systemImage: "doc.text")
                                .font(.caption2)
                                .foregroundStyle(SWARPColor.coolGray.opacity(0.72))
                            Spacer()
                            StatusBadge(title: order.status, tone: order.status == "Delivered" ? SWARPColor.success : SWARPColor.signal)
                        }
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SWARPColor.coolGray.opacity(0.55))
                }
            }
        }
        .buttonStyle(PressableScale())
    }
}
