import SwiftUI

struct SupportView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var focusedField: SupportField?
    @State private var selectedTopic: SupportTopic = .claim
    @State private var selectedOrderId: String?
    @State private var message = ""
    @State private var contactEmail = "eddine@swarppay.app"
    @State private var expandedQuestion: SupportQuestion.ID?
    @State private var submitState: SubmitState = .idle
    @State private var ticketReference: String?
    @State private var contentVisible = false

    let reference: String?

    private let orders = DemoFixtures.orders
    private let questions = SupportQuestion.defaults
    private let ticketHistory = SupportTicketPreview.defaults

    private var selectedOrder: VoucherOrder? {
        guard let selectedOrderId else { return nil }
        return orders.first { $0.id == selectedOrderId }
    }

    private var effectiveReference: String {
        reference ?? selectedOrder?.id ?? ""
    }

    private var canSubmit: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !contactEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        submitState != .submitting
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SWARPSpacing.md) {
            SupportHeroCard()
                .opacity(contentVisible ? 1 : 0)
                .offset(y: contentVisible || reduceMotion ? 0 : 12)

            SupportTopicGrid(selectedTopic: $selectedTopic) { topic in
                selectedTopic = topic
                if message.isEmpty {
                    message = topic.starterMessage(for: effectiveReference)
                }
            }

            if let reference, !reference.isEmpty {
                LinkedReferenceCard(reference: reference)
            }

            RecentOrderPicker(orders: orders, selectedOrderId: $selectedOrderId)

            SupportFormCard(
                selectedTopic: selectedTopic,
                selectedOrder: selectedOrder,
                effectiveReference: effectiveReference,
                contactEmail: $contactEmail,
                message: $message,
                focusedField: $focusedField,
                submitState: submitState,
                ticketReference: ticketReference,
                canSubmit: canSubmit,
                submit: submitTicket
            )

            SectionHeader(title: "Fast answers")
            VStack(spacing: 10) {
                ForEach(questions) { question in
                    SupportQuestionRow(
                        question: question,
                        isExpanded: expandedQuestion == question.id
                    ) {
                        withAnimation(SWARPMotion.smooth) {
                            expandedQuestion = expandedQuestion == question.id ? nil : question.id
                        }
                    }
                }
            }

            SectionHeader(title: "Recent support")
            VStack(spacing: 10) {
                ForEach(ticketHistory) { ticket in
                    SupportTicketPreviewRow(ticket: ticket)
                }
            }
        }
        .onAppear {
            if selectedOrderId == nil {
                selectedOrderId = orders.first { $0.id == reference }?.id
            }
            if let reference, !reference.isEmpty, message.isEmpty {
                message = selectedTopic.starterMessage(for: reference)
            }
            guard !contentVisible else { return }
            withAnimation(reduceMotion ? nil : SWARPMotion.enter) {
                contentVisible = true
            }
        }
    }

    private func submitTicket() {
        if submitState == .submitted {
            submitState = .idle
            ticketReference = nil
            message = selectedTopic.starterMessage(for: effectiveReference)
            focusedField = .message
            return
        }

        guard canSubmit else { return }
        focusedField = nil
        submitState = .submitting

        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = """
        Contact: \(contactEmail.trimmingCharacters(in: .whitespacesAndNewlines))
        Topic: \(selectedTopic.title)
        Reference: \(effectiveReference.isEmpty ? "No reference selected" : effectiveReference)

        \(trimmedMessage)
        """
        let draft = SupportTicketDraft(
            category: selectedTopic.rawValue,
            reference: effectiveReference,
            message: body
        )

        Task {
            do {
                let id = try await appState.api.submitSupport(draft)
                await MainActor.run {
                    Haptics.success()
                    ticketReference = id
                    submitState = .submitted
                    message = ""
                }
            } catch {
                await MainActor.run {
                    submitState = .failed("We could not create the support request. Please try again.")
                }
            }
        }
    }
}

private enum SupportField: Hashable {
    case email
    case message
}

private enum SubmitState: Equatable {
    case idle
    case submitting
    case submitted
    case failed(String)

    var buttonTitle: String {
        switch self {
        case .idle, .failed:
            return "Send request"
        case .submitting:
            return "Sending"
        case .submitted:
            return "Send another request"
        }
    }
}

private enum SupportTopic: String, CaseIterable, Identifiable {
    case claim
    case delivery
    case receipt
    case verification

    var id: String { rawValue }

    var title: String {
        switch self {
        case .claim: "Claim issue"
        case .delivery: "Delivery"
        case .receipt: "Receipt"
        case .verification: "Limits"
        }
    }

    var subtitle: String {
        switch self {
        case .claim: "Code, link, or redemption"
        case .delivery: "Voucher not delivered"
        case .receipt: "Invoice or order proof"
        case .verification: "Tier and limit questions"
        }
    }

    var symbolName: String {
        switch self {
        case .claim: "gift.fill"
        case .delivery: "paperplane.fill"
        case .receipt: "doc.text.fill"
        case .verification: "shield.checkered"
        }
    }

    func starterMessage(for reference: String) -> String {
        let referenceLine = reference.isEmpty ? "" : "\nReference: \(reference)"
        switch self {
        case .claim:
            return "I need help claiming a voucher.\(referenceLine)"
        case .delivery:
            return "My voucher has not arrived yet.\(referenceLine)"
        case .receipt:
            return "I need help finding or correcting a receipt.\(referenceLine)"
        case .verification:
            return "I need help with verification or purchase limits.\(referenceLine)"
        }
    }
}

private struct SupportHeroCard: View {
    var body: some View {
        SurfaceCard(padding: 18, prominence: .elevated) {
            HStack(alignment: .top, spacing: 14) {
                BrandedIcon(symbolName: "headphones", size: 54)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Support")
                        .font(.system(size: 26, weight: .semibold))
                        .tracking(-0.6)
                        .foregroundStyle(SWARPColor.cream)
                    Text("Get help with claims, voucher delivery, receipts, and account limits.")
                        .font(.subheadline)
                        .foregroundStyle(SWARPColor.coolGray)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        SupportSignalBadge(title: "Usually replies in 5 min", symbolName: "clock.fill")
                        SupportSignalBadge(title: "Order-aware help", symbolName: "bolt.fill")
                    }
                    .padding(.top, 2)
                }
            }
        }
    }
}

private struct SupportSignalBadge: View {
    let title: String
    let symbolName: String

    var body: some View {
        Label(title, systemImage: symbolName)
            .font(.caption2.weight(.bold))
            .foregroundStyle(SWARPColor.signal)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(SWARPColor.signal.opacity(0.10))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(SWARPColor.signal.opacity(0.18), lineWidth: 1))
    }
}

private struct SupportTopicGrid: View {
    @Binding var selectedTopic: SupportTopic
    let select: (SupportTopic) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "What do you need help with?")
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(SupportTopic.allCases) { topic in
                    SupportTopicButton(
                        topic: topic,
                        isSelected: selectedTopic == topic
                    ) {
                        select(topic)
                    }
                }
            }
        }
    }
}

private struct SupportTopicButton: View {
    let topic: SupportTopic
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: 10) {
                BrandedIcon(
                    symbolName: topic.symbolName,
                    size: 42,
                    accent: isSelected ? SWARPColor.signal : SWARPColor.coolGray
                )
                VStack(alignment: .leading, spacing: 3) {
                    Text(topic.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SWARPColor.cream)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                    Text(topic.subtitle)
                        .font(.caption2)
                        .foregroundStyle(SWARPColor.coolGray.opacity(0.78))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: SWARPRadius.lg, style: .continuous)
                    .fill(isSelected ? SWARPColor.signal.opacity(0.10) : .white.opacity(0.045))
                    .overlay(
                        RoundedRectangle(cornerRadius: SWARPRadius.lg, style: .continuous)
                            .stroke(isSelected ? SWARPColor.signal.opacity(0.32) : .white.opacity(0.10), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PressableScale())
    }
}

private struct LinkedReferenceCard: View {
    let reference: String

    var body: some View {
        SurfaceCard(padding: 14, prominence: .subtle) {
            HStack(spacing: 12) {
                BrandedIcon(symbolName: "link", size: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Linked reference")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SWARPColor.coolGray)
                    Text(reference)
                        .font(.caption.monospaced().weight(.semibold))
                        .foregroundStyle(SWARPColor.cream)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                }
            }
        }
    }
}

private struct RecentOrderPicker: View {
    let orders: [VoucherOrder]
    @Binding var selectedOrderId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Connect an order")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button {
                        Haptics.selection()
                        selectedOrderId = nil
                    } label: {
                        OrderReferenceChip(
                            title: "No order",
                            subtitle: "General support",
                            isSelected: selectedOrderId == nil
                        )
                    }
                    .buttonStyle(PressableScale())

                    ForEach(orders.prefix(5)) { order in
                        Button {
                            Haptics.selection()
                            selectedOrderId = order.id
                        } label: {
                            OrderReferenceChip(
                                title: order.productTitle,
                                subtitle: order.id,
                                isSelected: selectedOrderId == order.id
                            )
                        }
                        .buttonStyle(PressableScale())
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct OrderReferenceChip: View {
    let title: String
    let subtitle: String
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(SWARPColor.cream)
                .lineLimit(1)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(SWARPColor.coolGray.opacity(0.78))
                .lineLimit(1)
        }
        .frame(width: 146, alignment: .leading)
        .padding(12)
        .background(isSelected ? SWARPColor.signal.opacity(0.10) : .white.opacity(0.045))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? SWARPColor.signal.opacity(0.34) : .white.opacity(0.10), lineWidth: 1)
        )
    }
}

private struct SupportFormCard: View {
    let selectedTopic: SupportTopic
    let selectedOrder: VoucherOrder?
    let effectiveReference: String
    @Binding var contactEmail: String
    @Binding var message: String
    var focusedField: FocusState<SupportField?>.Binding
    let submitState: SubmitState
    let ticketReference: String?
    let canSubmit: Bool
    let submit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Create support request")

            SurfaceCard(padding: 14) {
                VStack(alignment: .leading, spacing: 12) {
                    SupportFormSummary(
                        selectedTopic: selectedTopic,
                        selectedOrder: selectedOrder,
                        reference: effectiveReference
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reply email")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(SWARPColor.coolGray)
                        TextField("you@example.com", text: $contactEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused(focusedField, equals: .email)
                            .submitLabel(.next)
                            .padding(12)
                            .foregroundStyle(SWARPColor.cream)
                            .background(.white.opacity(0.055))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.10), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Message")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(SWARPColor.coolGray)
                        TextEditor(text: $message)
                            .focused(focusedField, equals: .message)
                            .frame(minHeight: 128)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(SWARPColor.cream)
                            .background(.white.opacity(0.055))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.10), lineWidth: 1))
                            .overlay(alignment: .topLeading) {
                                if message.isEmpty {
                                    Text("Tell us what happened. Include the voucher code, order reference, or receipt details.")
                                        .font(.caption)
                                        .foregroundStyle(SWARPColor.coolGray.opacity(0.58))
                                        .padding(16)
                                        .allowsHitTesting(false)
                                }
                            }
                    }

                    SupportSubmitStatus(state: submitState, ticketReference: ticketReference)

                    Button {
                        submit()
                    } label: {
                        HStack {
                            if submitState == .submitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: submitState == .submitted ? "checkmark.seal.fill" : "paperplane.fill")
                            }
                            Text(submitState.buttonTitle)
                                .font(.subheadline.weight(.bold))
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(canSubmit || submitState == .submitted ? LinearGradient.swarpPrimaryAction : LinearGradient(colors: [.white.opacity(0.08), .white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(PressableScale())
                    .disabled(!canSubmit && submitState != .submitted)
                }
            }
        }
    }
}

private struct SupportFormSummary: View {
    let selectedTopic: SupportTopic
    let selectedOrder: VoucherOrder?
    let reference: String

    var body: some View {
        HStack(spacing: 12) {
            BrandedIcon(symbolName: selectedTopic.symbolName, size: 42)
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedTopic.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SWARPColor.cream)
                Text(summaryText)
                    .font(.caption)
                    .foregroundStyle(SWARPColor.coolGray)
                    .lineLimit(2)
            }
            Spacer()
        }
    }

    private var summaryText: String {
        if let selectedOrder {
            return "\(selectedOrder.productTitle) · \(selectedOrder.formattedAmount)"
        }
        if !reference.isEmpty {
            return reference
        }
        return "General support request"
    }
}

private struct SupportSubmitStatus: View {
    let state: SubmitState
    let ticketReference: String?

    var body: some View {
        switch state {
        case .idle, .submitting:
            EmptyView()
        case .submitted:
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(SWARPColor.success)
                Text("Request created\(ticketReference.map { ": \($0)" } ?? ".")")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SWARPColor.success)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SWARPColor.success.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        case .failed(let message):
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(SWARPColor.warning)
                Text(message)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SWARPColor.warning)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SWARPColor.warning.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct SupportQuestion: Identifiable {
    let id: String
    let title: String
    let answer: String
    let symbolName: String

    static let defaults: [SupportQuestion] = [
        SupportQuestion(
            id: "claim",
            title: "My voucher link does not open",
            answer: "Check that the full claim link or code was copied. If it still fails, send us the reference and we will inspect the claim state.",
            symbolName: "link.badge.plus"
        ),
        SupportQuestion(
            id: "delivery",
            title: "My voucher is not delivered",
            answer: "Most digital vouchers appear immediately. If a voucher remains active without a receipt, open a delivery request with the order reference.",
            symbolName: "paperplane"
        ),
        SupportQuestion(
            id: "receipt",
            title: "I need my receipt",
            answer: "Delivered vouchers include a receipt in My Vouchers. Support can resend or correct receipt details after review.",
            symbolName: "doc.text"
        ),
        SupportQuestion(
            id: "limits",
            title: "Why do I have a purchase limit?",
            answer: "Limits depend on verification tier and daily activity. Tier 2 users have higher daily and monthly limits.",
            symbolName: "shield"
        )
    ]
}

private struct SupportQuestionRow: View {
    let question: SupportQuestion
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    BrandedIcon(symbolName: question.symbolName, size: 40)
                    Text(question.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SWARPColor.cream)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SWARPColor.coolGray)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }

                if isExpanded {
                    Text(question.answer)
                        .font(.caption)
                        .foregroundStyle(SWARPColor.coolGray)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 52)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(12)
            .background(.white.opacity(0.045))
            .clipShape(RoundedRectangle(cornerRadius: SWARPRadius.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: SWARPRadius.lg).stroke(.white.opacity(0.10), lineWidth: 1))
        }
        .buttonStyle(PressableScale())
    }
}

private struct SupportTicketPreview: Identifiable {
    let id: String
    let title: String
    let detail: String
    let status: String
    let tone: Color

    static let defaults = [
        SupportTicketPreview(
            id: "SUP-8174",
            title: "Spotify claim question",
            detail: "Last update: support asked for claim reference",
            status: "Waiting",
            tone: SWARPColor.warning
        ),
        SupportTicketPreview(
            id: "SUP-6842",
            title: "Netflix receipt resend",
            detail: "Receipt sent to eddine@swarppay.app",
            status: "Solved",
            tone: SWARPColor.success
        )
    ]
}

private struct SupportTicketPreviewRow: View {
    let ticket: SupportTicketPreview

    var body: some View {
        SurfaceCard(padding: 12, prominence: .subtle) {
            HStack(spacing: 12) {
                BrandedIcon(symbolName: "bubble.left.and.text.bubble.right.fill", size: 42, accent: ticket.tone)
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SWARPColor.cream)
                        .lineLimit(1)
                    Text(ticket.detail)
                        .font(.caption)
                        .foregroundStyle(SWARPColor.coolGray)
                        .lineLimit(2)
                }
                Spacer()
                StatusBadge(title: ticket.status, tone: ticket.tone)
            }
        }
    }
}
