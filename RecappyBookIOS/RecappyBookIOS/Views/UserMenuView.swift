import SwiftUI

struct UserMenuView: View {

    let username: String
    let isAdmin: Bool
    let isGuest: Bool
    let onAddRecipe: () -> Void
    let onMyRecipes: () -> Void
    let onFavoriteRecipes: () -> Void
    let onMealPlan: () -> Void
    let onBlockedUsers: () -> Void
    let onDeleteProfile: () -> Void
    let onLogout: () -> Void
    let onExitGuest: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @StateObject private var viewModel = UserMenuViewModel()

    private let privacyPolicyURL = URL(string: "https://martinzajdlik.github.io/recappy-book-legal/")!
    private let termsOfUseURL = URL(string: "https://martinzajdlik.github.io/recappy-book-legal/terms.html")!

    private var isPad: Bool { horizontalSizeClass == .regular }
    private var avatarSize: CGFloat { isPad ? 110 : 76 }
    private var usernameFont: Font { isPad ? .largeTitle.bold() : .title2.bold() }
    private var rowFont: Font { isPad ? .title3 : .body }
    private var iconTileSize: CGFloat { isPad ? 36 : 30 }
    private var footerLinkFont: Font { isPad ? .callout : .footnote }
    private var contentMaxWidth: CGFloat? { isPad ? 520 : nil }

    /// Smazání účtu nabízíme jen běžným přihlášeným uživatelům (stejně jako dřív).
    private var showsAccountSettings: Bool { !isGuest && !isAdmin }

    var body: some View {
        NavigationStack {
            ScrollView {
                menuContent
            }
            .background(AppTheme.background)
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(AppTheme.green)
        .task {
            guard !isGuest else { return }
            viewModel.load(includeFavorites: !isAdmin)
        }
    }

    // MARK: - Obsah

    private var menuContent: some View {
        VStack(spacing: 22) {
            header
                .padding(.top, 28)

            addRecipeButton

            section("Moje kuchyně") {
                menuRow(
                    title: "Moje recepty",
                    icon: "book.fill",
                    tint: AppTheme.iconOrange,
                    trailing: AnyView(myRecipesBadges),
                    showsDivider: true
                ) {
                    dismiss()
                    onMyRecipes()
                }

                if !isAdmin {
                    menuRow(
                        title: "Oblíbené recepty",
                        icon: "star.fill",
                        tint: AppTheme.iconYellow,
                        trailing: viewModel.favoritesCount.map { AnyView(countText($0)) },
                        showsDivider: true
                    ) {
                        dismiss()
                        onFavoriteRecipes()
                    }
                }

                menuRow(
                    title: "Jídelníček",
                    subtitle: viewModel.todayMeal.map { "Dnes: \($0)" },
                    icon: "calendar",
                    tint: AppTheme.blue,
                    showsDivider: false
                ) {
                    dismiss()
                    onMealPlan()
                }
            }

            section("Účet") {
                if !isGuest {
                    menuRow(
                        title: "Zablokovaní uživatelé",
                        icon: "person.crop.circle.badge.xmark",
                        tint: AppTheme.iconGray,
                        showsDivider: true
                    ) {
                        dismiss()
                        onBlockedUsers()
                    }
                }

                if showsAccountSettings {
                    NavigationLink {
                        AccountSettingsView(username: username) {
                            dismiss()
                            onDeleteProfile()
                        }
                    } label: {
                        rowLabel(
                            title: "Nastavení účtu",
                            subtitle: nil,
                            icon: "gearshape.fill",
                            tint: AppTheme.iconGray,
                            trailing: nil,
                            showsChevron: true,
                            showsDivider: true
                        )
                    }
                    .buttonStyle(.plain)
                }

                if isGuest {
                    menuRow(
                        title: "Přihlásit se / Registrovat",
                        icon: "person.crop.circle.badge.plus",
                        tint: AppTheme.green,
                        showsChevron: false,
                        showsDivider: false
                    ) {
                        dismiss()
                        onExitGuest()
                    }
                } else {
                    menuRow(
                        title: "Odhlásit",
                        icon: "rectangle.portrait.and.arrow.right",
                        tint: AppTheme.iconGray,
                        showsChevron: false,
                        showsDivider: false
                    ) {
                        dismiss()
                        onLogout()
                    }
                }
            }

            footerLinks
                .padding(.top, 4)
                .padding(.bottom, 24)
        }
        .padding(.horizontal)
        .frame(maxWidth: contentMaxWidth)
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image("UserAvatar")
                .resizable()
                .scaledToFill()
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.green.opacity(0.6), lineWidth: 2))

            Text(username)
                .font(usernameFont)
                .foregroundStyle(AppTheme.text)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: isPad ? 360 : 260)

            if let stats = statsText {
                Text(stats)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedText)
            }
        }
    }

    private var statsText: String? {
        guard !isGuest, let recipes = viewModel.myRecipesCount else { return nil }
        var parts = [czechCount(recipes, one: "recept", few: "recepty", many: "receptů")]
        if !isAdmin, let favorites = viewModel.favoritesCount {
            parts.append(czechCount(favorites, one: "oblíbený", few: "oblíbené", many: "oblíbených"))
        }
        return parts.joined(separator: " · ")
    }

    private var addRecipeButton: some View {
        Button {
            dismiss()
            onAddRecipe()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                Text("Přidat recept")
            }
            .font(isPad ? .title3.bold() : .headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isPad ? 18 : 15)
            .background(AppTheme.green)
            .foregroundStyle(AppTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var myRecipesBadges: some View {
        HStack(spacing: 6) {
            if viewModel.rejectedCount > 0 {
                pill(
                    viewModel.rejectedCount == 1 ? "1 zamítnut" : "\(viewModel.rejectedCount) zamítnuto",
                    color: AppTheme.iconRed
                )
            }
            if viewModel.pendingCount > 0 {
                pill("\(viewModel.pendingCount) čeká", color: AppTheme.iconOrange)
            }
            if viewModel.rejectedCount == 0 && viewModel.pendingCount == 0,
               let count = viewModel.myRecipesCount {
                countText(count)
            }
        }
    }

    private var footerLinks: some View {
        HStack(spacing: 16) {
            Link(destination: privacyPolicyURL) {
                Text("Ochrana osobních údajů").underline()
            }
            Text("·")
            Link(destination: termsOfUseURL) {
                Text("Podmínky použití").underline()
            }
        }
        .font(footerLinkFont)
        .foregroundStyle(AppTheme.mutedText)
    }

    // MARK: - Stavební prvky

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.mutedText)
                .padding(.leading, 6)

            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func menuRow(
        title: String,
        subtitle: String? = nil,
        icon: String,
        tint: Color,
        trailing: AnyView? = nil,
        showsChevron: Bool = true,
        showsDivider: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            rowLabel(
                title: title,
                subtitle: subtitle,
                icon: icon,
                tint: tint,
                trailing: trailing,
                showsChevron: showsChevron,
                showsDivider: showsDivider
            )
        }
        .buttonStyle(.plain)
    }

    private func rowLabel(
        title: String,
        subtitle: String?,
        icon: String,
        tint: Color,
        trailing: AnyView?,
        showsChevron: Bool,
        showsDivider: Bool
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: iconTileSize * 0.5, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: iconTileSize, height: iconTileSize)
                    .background(tint)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(rowFont)
                        .foregroundStyle(AppTheme.text)

                    if let subtitle {
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.mutedText)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }

                Spacer(minLength: 8)

                if let trailing {
                    trailing
                }

                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.mutedText)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, isPad ? 14 : 11)
            .contentShape(Rectangle())

            if showsDivider {
                Rectangle()
                    .fill(AppTheme.separator)
                    .frame(height: 1)
                    .padding(.leading, 14 + iconTileSize + 12)
            }
        }
    }

    private func pill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color)
            .clipShape(Capsule())
    }

    private func countText(_ count: Int) -> some View {
        Text("\(count)")
            .font(.subheadline)
            .foregroundStyle(AppTheme.mutedText)
    }

    /// Česká množná čísla: 1 recept, 2–4 recepty, 0 a 5+ receptů.
    private func czechCount(_ count: Int, one: String, few: String, many: String) -> String {
        switch count {
        case 1: return "1 \(one)"
        case 2...4: return "\(count) \(few)"
        default: return "\(count) \(many)"
        }
    }
}

#Preview {
    UserMenuView(
        username: "user",
        isAdmin: false,
        isGuest: false,
        onAddRecipe: {},
        onMyRecipes: {},
        onFavoriteRecipes: {},
        onMealPlan: {},
        onBlockedUsers: {},
        onDeleteProfile: {},
        onLogout: {},
        onExitGuest: {}
    )
}
