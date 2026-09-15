import SwiftUI

struct AdminView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var selectedTab: AdminTab = .recipes
    @State private var showUserMenu = false
    @State private var showMealPlan = false
    @State private var showAddRecipe = false
    @State private var showMyRecipes = false
    @State private var showBlockedUsers = false
    @State private var pendingCount = 0
    @State private var reportedCount = 0
    @State private var recipesRefreshToken = UUID()
    
    enum AdminTab {
        case recipes
        case pending
        case reported
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
                    
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            adminTabButton(icon: "list.bullet.clipboard", title: "Recepty", tab: .recipes)
                            adminTabButton(icon: "person.2", title: "Uživatelé", tab: .users)
                        }
                        HStack(spacing: 10) {
                            adminTabButton(icon: "clock", title: "Ke schválení", tab: .pending)
                            adminTabButton(icon: "flag", title: "Nahlášené", tab: .reported)
                        }
                    }
                    .padding(.horizontal)

                    if selectedTab == .recipes {
                        adminRecipesSection
                    } else if selectedTab == .pending {
                        adminPendingRecipesSection
                    } else if selectedTab == .reported {
                        adminReportedRecipesSection
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
            .trulyHideNavigationBar()
            .safeAreaInset(edge: .bottom) {
                if verticalSizeClass != .compact {
                    FooterView()
                        .background(AppTheme.background)
                }
            }
            .navigationDestination(isPresented: $showMealPlan) {
                MealPlanView()
            }
            .navigationDestination(isPresented: $showMyRecipes) {
                MyRecipesView()
            }
            .navigationDestination(isPresented: $showBlockedUsers) {
                BlockedUsersView()
            }
        }
        .task {
            await loadPendingCount()
            await loadReportedCount()
        }
        .onChange(of: selectedTab) { _, _ in
            Task {
                await loadPendingCount()
                await loadReportedCount()
            }
        }
        .sheet(isPresented: $showUserMenu) {
            UserMenuView(
                username: UserDefaults.standard.string(forKey: "currentUsername") ?? "",
                isAdmin: authViewModel.role == "ROLE_ADMIN",
                isGuest: false,
                onAddRecipe: {
                    showAddRecipe = true
                },
                onMyRecipes: {
                    showMyRecipes = true
                },
                onFavoriteRecipes: {
                },
                onMealPlan: {
                    showMealPlan = true
                },
                onBlockedUsers: {
                    showBlockedUsers = true
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
        .sheet(isPresented: $showAddRecipe) {
            NavigationStack {
                RecipeFormView(recipe: nil) {}
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showAddRecipe = false
                            } label: {
                                Label("Zpět", systemImage: "chevron.left")
                            }
                        }
                    }
            }
        }
        .onChange(of: showAddRecipe) { _, isPresented in
            if !isPresented {
                recipesRefreshToken = UUID()
            }
        }
    }

    private var adminRecipesSection: some View {
        AdminRecipesView()
            .id(recipesRefreshToken)
    }

    private var adminPendingRecipesSection: some View {
        AdminPendingRecipesView {
            Task {
                await loadPendingCount()
            }
        }
    }

    private var adminReportedRecipesSection: some View {
        AdminReportedRecipesView {
            Task {
                await loadReportedCount()
            }
        }
    }

    private func loadPendingCount() async {
        pendingCount = (try? await APIService.shared.fetchPendingRecipesCount()) ?? pendingCount
    }

    private func loadReportedCount() async {
        reportedCount = (try? await APIService.shared.fetchReportedRecipesCount()) ?? reportedCount
    }

    private var adminUsersSection: some View {
        AdminUsersView()
    }
    
    private func badgeCount(for tab: AdminTab) -> Int? {
        switch tab {
        case .pending: return pendingCount
        case .reported: return reportedCount
        default: return nil
        }
    }

    private func adminTabButton(icon: String, title: String, tab: AdminTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(selectedTab == tab ? AppTheme.green : AppTheme.card)
            .foregroundStyle(selectedTab == tab ? .black : .white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                if let badgeCount = badgeCount(for: tab), badgeCount > 0 {
                    Text(badgeCount > 99 ? "99+" : "\(badgeCount)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .offset(x: 8, y: -8)
                }
            }
        }
    }
}

#Preview {
    AdminView(authViewModel: AuthViewModel())
}
