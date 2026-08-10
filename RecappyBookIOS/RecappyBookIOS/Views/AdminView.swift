import SwiftUI

struct AdminView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var selectedTab: AdminTab = .recipes
    @State private var showUserMenu = false
    @State private var pendingCount = 0
    
    enum AdminTab {
        case recipes
        case pending
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
                        adminTabButton(title: "🕓 Ke schválení", tab: .pending)
                        adminTabButton(title: "👤 Uživatelé", tab: .users)
                    }
                    .padding(.horizontal)

                    if selectedTab == .recipes {
                        adminRecipesSection
                    } else if selectedTab == .pending {
                        adminPendingRecipesSection
                    } else {
                        adminUsersSection
                    }

                    if verticalSizeClass == .compact {
                        FooterView()
                    }
                }
                .padding(.top, 0)
            }
            .background(AppTheme.background)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                if verticalSizeClass != .compact {
                    FooterView()
                        .background(AppTheme.background)
                }
            }
        }
        .task {
            await loadPendingCount()
        }
        .onChange(of: selectedTab) { _, _ in
            Task {
                await loadPendingCount()
            }
        }
        .sheet(isPresented: $showUserMenu) {
            UserMenuView(
                username: UserDefaults.standard.string(forKey: "currentUsername") ?? "",
                isAdmin: authViewModel.role == "ROLE_ADMIN",
                isGuest: false,
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
                },
                onExitGuest: {}
            )
        }
        
        
    }
    
    private var adminRecipesSection: some View {
        AdminRecipesView()
    }

    private var adminPendingRecipesSection: some View {
        AdminPendingRecipesView {
            Task {
                await loadPendingCount()
            }
        }
    }

    private func loadPendingCount() async {
        pendingCount = (try? await APIService.shared.fetchPendingRecipesCount()) ?? pendingCount
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
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == tab ? AppTheme.green : AppTheme.card)
                .foregroundStyle(selectedTab == tab ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(alignment: .topTrailing) {
                    if tab == .pending && pendingCount > 0 {
                        Text(pendingCount > 99 ? "99+" : "\(pendingCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 10, y: -10)
                    }
                }
        }
    }
}

#Preview {
    AdminView(authViewModel: AuthViewModel())
}
