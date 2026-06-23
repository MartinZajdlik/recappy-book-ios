import SwiftUI

struct ContentView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = RecipeViewModel()
    @State private var showUserMenu = false
    @State private var showAddRecipe = false
    
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
                                            RecipeCardView(recipe: recipe)
                                        }
                                        .buttonStyle(.plain)
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
            await viewModel.loadRecipes()
        }
        .sheet(isPresented: $showUserMenu) {
            UserMenuView(
                username: UserDefaults.standard.string(forKey: "currentUsername") ?? "",
                onAddRecipe: {
                    showAddRecipe = true
                },
                onMyRecipes: {
                    print("Moje recepty později")
                },
                onDeleteProfile: {
                    print("Smazání profilu později")
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
    }
}

#Preview {
    ContentView(authViewModel: AuthViewModel())
}
