import SwiftUI

struct ContentView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = RecipeViewModel()
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showUserMenu = false
    /// Akce z uživatelského menu, které mění celou obrazovku (odhlášení, …), se smí
    /// spustit až po úplném zavření sheetu. Jinak zůstane rozpracovaná prezentace a
    /// textová pole na další obrazovce nepřijmou klávesnici.
    @State private var pendingMenuAction: (() -> Void)?
    @State private var showAddRecipe = false
    @State private var showMyRecipes = false
    @State private var showDeleteProfileAlert = false
    @State private var showFavoriteRecipes = false
    @State private var showMealPlan = false
    @State private var showBlockedUsers = false
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    HeaderView(
                        username: authViewModel.isGuest ? "Host" : UserDefaults.standard.string(forKey: "currentUsername"),
                        showUserControls: true,
                        onLogoTap: {
                            viewModel.clearCategory()
                            viewModel.clearSearch()
                        },
                        onUserMenuTap: {
                            showUserMenu = true
                        }
                    )
                    
                    SearchBarView(text: $viewModel.searchText)
                        .padding(.horizontal, 14)

                    HStack(spacing: 8) {
                        
                        CategoryButtonView(title: "Polévky", icon: "cup.and.saucer.fill", isSelected: !viewModel.isSearching && viewModel.selectedCategory == "Polévky") {
                            viewModel.selectCategory("Polévky")
                        }
                        
                        CategoryButtonView(title: "Hlavní\njídla", icon: "fork.knife.circle", isSelected: !viewModel.isSearching && viewModel.selectedCategory == "Hlavní jídla") {
                            viewModel.selectCategory("Hlavní jídla")
                        }
                        
                        CategoryButtonView(title: "Dezerty", icon: "birthday.cake", isSelected: !viewModel.isSearching && viewModel.selectedCategory == "Dezerty") {
                            viewModel.selectCategory("Dezerty")
                        }
                        
                        CategoryButtonView(title: "Snídaně", icon: "frying.pan.fill", isSelected: !viewModel.isSearching && viewModel.selectedCategory == "Snídaně") {
                            viewModel.selectCategory("Snídaně")
                        }
                        
                        CategoryButtonView(title: "Ostatní", icon: "takeoutbag.and.cup.and.straw", isSelected: !viewModel.isSearching && viewModel.selectedCategory == "Ostatní") {
                            viewModel.selectCategory("Ostatní")
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    Group {
                        if viewModel.isLoading {
                            
                            ProgressView("Načítám recepty...")
                                .foregroundStyle(.white)
                            
                        } else if let error = viewModel.errorMessage {
                            
                            Text(error)
                                .foregroundStyle(.red)
                            
                        } else {
                            
                            if viewModel.showsRecipeList || viewModel.dailyTip == nil {
                                let results = viewModel.filteredRecipes
                                if results.isEmpty && viewModel.isSearching {
                                    noSearchResultsView
                                } else {
                                    recipeList(results)
                                }
                            } else if let recipe = viewModel.dailyTip {
                                VStack(spacing: 16) {
                                    Text("TIP na dnešní den")
                                        .font(.system(size: 20, weight: .heavy))
                                        .foregroundStyle(AppTheme.blue)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 14)
                                    
                                    NavigationLink {
                                        RecipeDetailView(recipe: recipe, onToggleFavorite: {
                                            if authViewModel.guardGuest() { return nil }
                                            return await viewModel.toggleFavorite(for: recipe)
                                        })
                                    } label: {
                                        DailyTipCardView(recipe: recipe)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 14)
                                }
                            }
                        }
                    }

                    if verticalSizeClass == .compact {
                        FooterView()
                    }

                }
                .padding(.top, 0)
            }
            .background(AppTheme.background)
            .autoRefresh {
                await viewModel.refresh()
            }
            .trulyHideNavigationBar()
            .safeAreaInset(edge: .bottom) {
                if verticalSizeClass != .compact {
                    FooterView()
                        .background(AppTheme.background)
                }
            }
            .navigationDestination(isPresented: $showMyRecipes) {
                MyRecipesView()
            }
            .navigationDestination(isPresented: $showFavoriteRecipes) {
                FavoriteRecipesView()
            }
            .navigationDestination(isPresented: $showMealPlan) {
                MealPlanView()
            }
            .navigationDestination(isPresented: $showBlockedUsers) {
                BlockedUsersView()
            }
        }
        .task {
            await viewModel.loadRecipesIfNeeded()
        }
        .sheet(isPresented: $showUserMenu, onDismiss: runPendingMenuAction) {
            UserMenuView(
                username: authViewModel.isGuest ? "Host" : (UserDefaults.standard.string(forKey: "currentUsername") ?? ""),
                isAdmin: authViewModel.role == "ROLE_ADMIN",
                isGuest: authViewModel.isGuest,
                onAddRecipe: {
                    if authViewModel.guardGuest() { return }
                    showAddRecipe = true
                },
                onMyRecipes: {
                    if authViewModel.guardGuest() { return }
                    showMyRecipes = true
                },
                onFavoriteRecipes: {
                    if authViewModel.guardGuest() { return }
                    showFavoriteRecipes = true
                },
                onMealPlan: {
                    if authViewModel.guardGuest() { return }
                    showMealPlan = true
                },
                onBlockedUsers: {
                    if authViewModel.guardGuest() { return }
                    showBlockedUsers = true
                },
                onDeleteProfile: {
                    pendingMenuAction = { showDeleteProfileAlert = true }
                },
                onLogout: {
                    pendingMenuAction = { authViewModel.logout() }
                },
                onExitGuest: {
                    pendingMenuAction = { authViewModel.exitGuestMode() }
                }
            )
        }
        .sheet(isPresented: $showAddRecipe) {
            NavigationStack {
                RecipeFormView(recipe: nil) {
                    Task {
                        await viewModel.loadRecipes()
                    }
                }
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
            .presentationSizing(.page)
        }
        .onChange(of: showAddRecipe) { _, isPresented in
            if !isPresented {
                Task {
                    await viewModel.loadRecipes()
                }
            }
        }
        .onChange(of: showMyRecipes) { _, isPresented in
            if !isPresented {
                Task {
                    await viewModel.loadRecipes()
                }
            }
        }
        .onChange(of: showFavoriteRecipes) { _, isPresented in
            if !isPresented {
                Task {
                    await viewModel.loadRecipes()
                }
            }
        }
        
        .alert("Smazat účet?", isPresented: $showDeleteProfileAlert) {
            Button("Zrušit", role: .cancel) {}

            Button("Smazat", role: .destructive) {
                Task {
                    await authViewModel.deleteMyAccount()
                }
            }
        } message: {
            Text("Opravdu chceš smazat svůj účet? Smažou se také všechny tvoje recepty. Tuto akci nelze vrátit.")
        }

        .alert("Jsi přihlášen/a jako host", isPresented: $authViewModel.showGuestAlert) {
            Button("Zavřít", role: .cancel) {}

            Button("Přihlásit se") {
                authViewModel.exitGuestMode()
            }
        } message: {
            Text("Jako host nemůžeš používat některé funkce. Zaregistruj se nebo se přihlas.")
        }

    }

    private func runPendingMenuAction() {
        let action = pendingMenuAction
        pendingMenuAction = nil
        action?()
    }

    // MARK: - Seznam receptů a výsledky hledání

    private func recipeList(_ recipes: [Recipe]) -> some View {
        LazyVStack(spacing: 16) {
            ForEach(recipes) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe, onToggleFavorite: {
                        if authViewModel.guardGuest() { return nil }
                        return await viewModel.toggleFavorite(for: recipe)
                    })
                } label: {
                    RecipeCardView(
                        recipe: recipe,
                        onFavoriteTap: {
                            if authViewModel.guardGuest() { return }
                            Task {
                                await viewModel.toggleFavorite(for: recipe)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var noSearchResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(AppTheme.mutedText)

            Text("Nic jsme nenašli pro „\(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines))“")
                .font(.headline)
                .foregroundStyle(AppTheme.text)
                .multilineTextAlignment(.center)

            Button("Zrušit hledání") {
                viewModel.clearSearch()
            }
            .font(.headline)
            .foregroundStyle(AppTheme.green)
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }
}

#Preview {
    ContentView(authViewModel: AuthViewModel())
}

struct DailyTipCardView: View {
    
    let recipe: Recipe

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var imageHeight: CGFloat {
        horizontalSizeClass == .regular ? 380 : 220
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            Text(recipe.title)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(AppTheme.green)
            
            if let imageUrl = recipe.imageUrl,
               let url = URL(string: optimizedImageUrl(imageUrl, width: 900)) {
                
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(AppTheme.categoryCard)
                        
                        ProgressView()
                    }
                }
                .frame(height: imageHeight)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            
            VStack(alignment: .leading, spacing: 6) {

                HStack(spacing: 4) {
                    Text("Kategorie:")
                        .foregroundStyle(AppTheme.mutedText)

                    Text(recipe.category ?? "Bez kategorie")
                        .foregroundStyle(AppTheme.text)
                }
                .font(.title3)

                HStack(spacing: 4) {
                    Text("Autor:")
                        .foregroundStyle(AppTheme.mutedText)

                    Text(recipe.authorUsername ?? "Neznámý autor")
                        .foregroundStyle(AppTheme.text)
                }
                .font(.title3)
            }
        }
        .padding(16)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}
