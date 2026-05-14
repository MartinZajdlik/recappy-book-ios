import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = RecipeViewModel()
    
    var body: some View {
        
        NavigationStack {
            
            Group {
                
                if viewModel.isLoading {
                    
                    ProgressView("Načítám recepty...")
                    
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
                }
            }
            .navigationTitle("RecAPPy Book")
        }
        .task {
            await viewModel.loadRecipes()
        }
    }
}

#Preview {
    ContentView()
}
