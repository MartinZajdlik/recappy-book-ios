import SwiftUI

struct ContentView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = RecipeViewModel()
    @State private var showUserMenu = false
    @State private var showAddRecipe = false
    @State private var showMyRecipes = false
    @State private var showDeleteProfileAlert = false
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    HeaderView(
                        username: UserDefaults.standard.string(forKey: "currentUsername"),
                        showUserControls: true,
                        onLogoTap: {
                            viewModel.clearCategory()
                        },
                        onUserMenuTap: {
                            showUserMenu = true
                        }
                    )
                    
                    HStack(spacing: 8) {
                        
                        CategoryButtonView(title: "Polévky", icon: "cup.and.saucer.fill") {
                            viewModel.selectCategory("Polévky")
                        }
                        
                        CategoryButtonView(title: "Hlavní\njídla", icon: "fork.knife.circle") {
                            viewModel.selectCategory("Hlavní jídla")
                        }
                        
                        CategoryButtonView(title: "Dezerty", icon: "birthday.cake") {
                            viewModel.selectCategory("Dezerty")
                        }
                        
                        CategoryButtonView(title: "Snídaně", icon: "frying.pan.fill") {
                            viewModel.selectCategory("Snídaně")
                        }
                        
                        CategoryButtonView(title: "Ostatní", icon: "takeoutbag.and.cup.and.straw") {
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
                            
                            if viewModel.selectedCategory == nil {
                                if let recipe = viewModel.dailyTip {
                                    VStack(spacing: 16) {
                                        Text("TIP na dnešní den")
                                            .font(.system(size: 20, weight: .heavy))
                                            .foregroundStyle(AppTheme.blue)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 14)
                                        
                                        NavigationLink {
                                            RecipeDetailView(recipe: recipe)
                                        } label: {
                                            DailyTipCardView(recipe: recipe)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.horizontal, 14)
                                    }
                                } else {
                                    // Fallback: if no dailyTip yet, show list
                                    LazyVStack(spacing: 16) {
                                        ForEach(viewModel.filteredRecipes) { recipe in
                                            NavigationLink {
                                                RecipeDetailView(recipe: recipe)
                                            } label: {
                                                RecipeCardView(recipe: recipe)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.filteredRecipes) { recipe in
                                        NavigationLink {
                                            RecipeDetailView(recipe: recipe)
                                        } label: {
                                            RecipeCardView(recipe: recipe)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
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
        .task {
            await viewModel.loadRecipesIfNeeded()
        }
        .sheet(isPresented: $showUserMenu) {
            UserMenuView(
                username: UserDefaults.standard.string(forKey: "currentUsername") ?? "",
                isAdmin: authViewModel.role == "ROLE_ADMIN",
                onAddRecipe: {
                    showAddRecipe = true
                },
                onMyRecipes: {
                    showMyRecipes = true
                },
                onDeleteProfile: {
                    showDeleteProfileAlert = true
                },
                onLogout: {
                    authViewModel.logout()
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
        }
        .sheet(isPresented: $showMyRecipes) {
            NavigationStack {
                MyRecipesView()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showMyRecipes = false
                            } label: {
                                Label("Zpět", systemImage: "chevron.left")
                            }
                        }
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
        
        
    }
}

#Preview {
    ContentView(authViewModel: AuthViewModel())
}

struct DailyTipCardView: View {
    
    let recipe: Recipe
    
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
                .frame(height: 220)
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
