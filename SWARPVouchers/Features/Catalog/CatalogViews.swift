import SwiftUI

struct CatalogView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedCategory: VoucherCategory?
    @State private var searchText = ""
    private let products = DemoFixtures.products

    init(initialCategory: VoucherCategory? = nil) {
        _selectedCategory = State(initialValue: initialCategory)
    }

    private var filteredProducts: [VoucherProduct] {
        products.filter { product in
            let categoryMatches = selectedCategory == nil || product.category == selectedCategory
            let queryMatches = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || product.matches(searchText)
            return categoryMatches && queryMatches
        }
    }

    private var availableCategories: [VoucherCategory] {
        VoucherCategory.allCases.filter { category in
            products.contains { $0.category == category }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SWARPSpacing.md) {
            CatalogHeader(productCount: filteredProducts.count)
            CatalogSearchField(searchText: $searchText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryChip(title: "All", symbolName: nil, isSelected: selectedCategory == nil) {
                        setCategory(nil)
                    }
                    ForEach(availableCategories, id: \.self) { category in
                        CategoryChip(title: category.displayName, symbolName: category.symbolName, isSelected: selectedCategory == category) {
                            setCategory(category)
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            if filteredProducts.isEmpty {
                CatalogEmptyState(searchText: searchText) {
                    withAnimation(SWARPMotion.smooth) {
                        searchText = ""
                        selectedCategory = nil
                    }
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(filteredProducts) { product in
                        CatalogProductRow(product: product) {
                            appState.path.append(AppRoute.product(product.id))
                        }
                    }
                }
                .animation(SWARPMotion.smooth, value: filteredProducts)
            }
        }
    }

    private func setCategory(_ category: VoucherCategory?) {
        Haptics.selection()
        withAnimation(SWARPMotion.smooth) {
            selectedCategory = category
        }
    }
}

struct CategoryDetailView: View {
    let category: VoucherCategory

    var body: some View {
        CatalogView(initialCategory: category)
    }
}

private struct CategoryChip: View {
    let title: String
    let symbolName: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let symbolName {
                    Image(systemName: symbolName)
                        .font(.caption.weight(.semibold))
                }
                Text(title)
                    .font(.caption.weight(.bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .foregroundStyle(isSelected ? SWARPColor.cream : SWARPColor.coolGray)
            .background(isSelected ? SWARPColor.electricBlue.opacity(0.24) : .white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? SWARPColor.signal.opacity(0.35) : .white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(PressableScale())
    }
}

private struct CatalogHeader: View {
    let productCount: Int

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Catalog")
                    .font(.title.bold())
                    .foregroundStyle(SWARPColor.cream)
                Text("Frontend preview of digital voucher inventory.")
                    .font(.subheadline)
                    .foregroundStyle(SWARPColor.coolGray)
            }
            Spacer()
            StatusBadge(title: "\(productCount) shown", tone: SWARPColor.minted)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct CatalogSearchField: View {
    @Binding var searchText: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline.bold())
                .foregroundStyle(isFocused ? SWARPColor.signal : SWARPColor.coolGray)
            TextField("Search vouchers, brands, categories", text: $searchText)
                .font(.subheadline)
                .foregroundStyle(SWARPColor.cream)
                .tint(SWARPColor.signal)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isFocused)
            if !searchText.isEmpty {
                Button {
                    withAnimation(SWARPMotion.quick) {
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(SWARPColor.coolGray)
                }
                .buttonStyle(PressableScale())
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: SWARPRadius.lg, style: .continuous)
                .fill(isFocused ? SWARPColor.elevatedPanel.opacity(0.82) : SWARPColor.cream.opacity(0.045))
                .overlay(
                    RoundedRectangle(cornerRadius: SWARPRadius.lg, style: .continuous)
                        .stroke(isFocused ? SWARPColor.signal.opacity(0.38) : .white.opacity(0.10), lineWidth: 1)
                )
        )
        .animation(SWARPMotion.quick, value: isFocused)
    }
}

private struct CatalogEmptyState: View {
    let searchText: String
    let resetAction: () -> Void

    var body: some View {
        SurfaceCard(padding: SWARPSpacing.lg, cornerRadius: SWARPRadius.xl, prominence: .subtle) {
            VStack(alignment: .leading, spacing: SWARPSpacing.md) {
                BrandedIcon(symbolName: "magnifyingglass", size: 54, accent: SWARPColor.gold)
                Text("No vouchers found")
                    .font(.headline.bold())
                    .foregroundStyle(SWARPColor.cream)
                Text(searchText.isEmpty ? "Try a different category." : "Try another brand, category, or shorter search term.")
                    .font(.subheadline)
                    .foregroundStyle(SWARPColor.coolGray)
                Button("Reset filters", action: resetAction)
                    .font(.subheadline.bold())
                    .foregroundStyle(SWARPColor.signal)
            }
        }
    }
}

private extension VoucherProduct {
    func matches(_ rawQuery: String) -> Bool {
        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return true }

        return brand.lowercased().contains(query)
            || shortBrand.lowercased().contains(query)
            || category.displayName.lowercased().contains(query)
            || notes.lowercased().contains(query)
            || range.lowercased().contains(query)
    }
}
