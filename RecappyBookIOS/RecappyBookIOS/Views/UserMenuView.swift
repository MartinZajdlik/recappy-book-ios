import SwiftUI

struct UserMenuView: View {
    
    let username: String
    let isAdmin: Bool
    let onAddRecipe: () -> Void
    let onMyRecipes: () -> Void
    let onDeleteProfile: () -> Void
    let onLogout: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            
            HeaderView(onLogoTap: {})
            
            VStack(spacing: 8) {
                Text("👨‍🍳")
                    .font(.system(size: 46))
                
                Text(username)
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.green)
                    .lineLimit(1)
                    .truncationMode(.tail)
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
            }

            Spacer()

            VStack(spacing: 14) {
                menuButton(title: "Odhlásit", icon: "rectangle.portrait.and.arrow.right") {
                    dismiss()
                    onLogout()
                }
                
                if !isAdmin {
                    menuButton(title: "Smazat profil", icon: "trash.fill", isDestructive: true) {
                        dismiss()
                        onDeleteProfile()
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.background)
    }
    
    private func menuButton(
        title: String,
        icon: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.headline)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
        
            }
            .padding()
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
        isAdmin: true ,
        onAddRecipe: {},
        onMyRecipes: {},
        onDeleteProfile: {},
        onLogout: {}
    )
}
