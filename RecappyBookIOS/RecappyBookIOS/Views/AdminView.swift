import SwiftUI

struct AdminView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    @State private var selectedTab: AdminTab = .recipes
    @State private var showUserMenu = false
    
    enum AdminTab {
        case recipes
        case users
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    HeaderView(
                        username: UserDefaults.standard.string(forKey: "currentUsername"),
                        showUserControls: true,
                        onLogoTap: {},
                        onUserMenuTap: {
                            showUserMenu = true
                        }
                       
                    )
                    
                    HStack(spacing: 12) {
                        adminTabButton(title: "📋 Recepty", tab: .recipes)
                        adminTabButton(title: "👤 Uživatelé", tab: .users)
                    }
                    .padding(.horizontal)
                    
                    if selectedTab == .recipes {
                        adminRecipesSection
                    } else {
                        adminUsersSection
                    }
                }
                .padding(.top, 0)
                .padding(.bottom, 90)
            }
            .background(AppTheme.background)
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                FooterView()
                    .background(AppTheme.background)
            }
        }
        .sheet(isPresented: $showUserMenu) {
            UserMenuView(
                username: UserDefaults.standard.string(forKey: "currentUsername") ?? "",isAdmin: authViewModel.role == "ROLE_ADMIN",
                onAddRecipe: {
                    print("Admin přidat recept později")
                },
                onMyRecipes: {
                    print("Moje recepty později")
                },
                onFavoriteRecipes: {
                },
                onDeleteProfile: {
                    print("Smazání profilu později")
                },
                onLogout: {
                    authViewModel.logout()
                }
            )
        }
        
        
    }
    
    private var adminRecipesSection: some View {
        AdminRecipesView()
    }
    
    private var adminUsersSection: some View {
        AdminUsersView()
    }
    
    private func adminTabButton(title: String, tab: AdminTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == tab ? AppTheme.green : AppTheme.card)
                .foregroundStyle(selectedTab == tab ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    AdminView(authViewModel: AuthViewModel())
}
