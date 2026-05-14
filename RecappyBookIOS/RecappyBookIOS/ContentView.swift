import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = RecipeViewModel()
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    HeaderView()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
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
                        .padding(.horizontal, 20)
                    }
                    
                    Group {
                        
                        if viewModel.isLoading {
                            
                            ProgressView("Načítám recepty...")
                                .foregroundStyle(.white)
                            
                        } else if let error = viewModel.errorMessage {
                            
                            Text(error)
                                .foregroundStyle(.red)
                            
                        } else {
                            
                            List(viewModel.recipes) { recipe in
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    Text(recipe.title)
                                        .font(.headline)
                                    
                                    Text(recipe.category ?? "Bez kategorie")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                            .frame(height: 500)
                        }
                    }
                }
                .padding(.bottom, 24)
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
