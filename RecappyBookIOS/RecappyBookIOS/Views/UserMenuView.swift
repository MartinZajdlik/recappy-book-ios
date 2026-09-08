import SwiftUI

struct UserMenuView: View {
    
    let username: String
    let isAdmin: Bool
    let isGuest: Bool
    let onAddRecipe: () -> Void
    let onMyRecipes: () -> Void
    let onFavoriteRecipes: () -> Void
    let onMealPlan: () -> Void
    let onDeleteProfile: () -> Void
    let onLogout: () -> Void
    let onExitGuest: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let privacyPolicyURL = URL(string: "https://martinzajdlik.github.io/recappy-book-legal/")!
    private let termsOfUseURL = URL(string: "https://martinzajdlik.github.io/recappy-book-legal/terms.html")!

    private var isPad: Bool { horizontalSizeClass == .regular }
    private var avatarSize: CGFloat { isPad ? 110 : 72 }
    private var usernameFont: Font { isPad ? .largeTitle.bold() : .title2.bold() }
    private var menuFont: Font { isPad ? .title2 : .headline }
    private var menuIconFont: Font { isPad ? .title2 : .headline }
    private var footerLinkFont: Font { isPad ? .callout : .footnote }
    private var contentMaxWidth: CGFloat? { isPad ? 460 : nil }
    
    var body: some View {
        VStack(spacing: 24) {

            Spacer().frame(height: 24)

            VStack(spacing: 8) {
                Image("UserAvatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: avatarSize, height: avatarSize)
                    .clipShape(Circle())
                
                Text(username)
                    .font(usernameFont)
                    .foregroundStyle(AppTheme.green)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: isPad ? 360 : 260)
            }
            
            VStack(spacing: 14) {
                menuButton(title: "Přidat recept", icon: "plus.circle.fill") {
                    dismiss()
                    onAddRecipe()
                }
                
                menuButton(title: "Moje recepty", icon: "book.fill") {
                    dismiss()
                    onMyRecipes()
                }

                if !isAdmin {
                    menuButton(title: "Oblíbené recepty", icon: "star.fill") {
                        dismiss()
                        onFavoriteRecipes()
                    }
                }

                menuButton(title: "Jídelníček", icon: "calendar") {
                    dismiss()
                    onMealPlan()
                }
            }

            Spacer()

            VStack(spacing: 14) {
                if isGuest {
                    menuButton(title: "Přihlásit se / Registrovat", icon: "person.crop.circle.badge.plus") {
                        dismiss()
                        onExitGuest()
                    }
                } else {
                    menuButton(title: "Odhlásit", icon: "rectangle.portrait.and.arrow.right") {
                        dismiss()
                        onLogout()
                    }
                }
            }

            if !isGuest && !isAdmin {
                Spacer().frame(height: 24)

                Divider()
                    .background(AppTheme.mutedText.opacity(0.3))

                Spacer().frame(height: 24)

                menuButton(title: "Smazat profil", icon: "trash.fill", isDestructive: true) {
                    dismiss()
                    onDeleteProfile()
                }
            }

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
            .padding(.top, 4)

            Spacer()
        }
        .padding()
        .frame(maxWidth: contentMaxWidth)
        .frame(maxWidth: .infinity)
        .background(AppTheme.background)
    }
    
    private func menuButton(
        title: String,
        icon: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: isPad ? 16 : 12) {
                Image(systemName: icon)
                    .font(menuIconFont)
                
                Text(title)
                    .font(menuFont)
                
                Spacer()
                
        
            }
            .padding(isPad ? 20 : 16)
            .background(AppTheme.card)
            .foregroundStyle(isDestructive ? .red : AppTheme.text)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    UserMenuView(
        username: "admin",
        isAdmin: true,
        isGuest: false,
        onAddRecipe: {},
        onMyRecipes: {},
        onFavoriteRecipes: {},
        onMealPlan: {},
        onDeleteProfile: {},
        onLogout: {},
        onExitGuest: {}
    )
}
