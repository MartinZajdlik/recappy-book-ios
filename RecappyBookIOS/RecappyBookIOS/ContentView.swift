import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = RecipeViewModel()
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    HeaderView()
                    
                    HStack(spacing: 8) {
                        CategoryButtonView(title: "Polévky", icon: "fork.knife") {
                            print("Polévky")
                        }
                        
                        CategoryButtonView(title: "Hlavní\njídla", icon: "plate") {
                            print("Hlavní jídla")
                        }
                        
                        CategoryButtonView(title: "Dezerty", icon: "cupcake") {
                            print("Dezerty")
                        }
                        
                        CategoryButtonView(title: "Snídaně", icon: "sunrise") {
                            print("Snídaně")
                        }
                        
                        CategoryButtonView(title: "Ostatní", icon: "takeoutbag.and.cup.and.straw") {
                            print("Ostatní")
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
                            
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.recipes) { recipe in
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
                .padding(.top, 35)
                .padding(.bottom, 30)
            }
            .background(AppTheme.background)
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.loadRecipes()
        }
    }
}

#Preview {
    ContentView()
}
