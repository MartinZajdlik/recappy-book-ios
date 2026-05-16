import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = RecipeViewModel()
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    HeaderView(onLogoTap: {
                        viewModel.clearCategory()
                    })
                    
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
                .padding(.top, 35)
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
    }
}

#Preview {
    ContentView()
}
