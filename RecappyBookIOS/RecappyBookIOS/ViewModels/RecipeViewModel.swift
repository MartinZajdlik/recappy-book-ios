import SwiftUI
import Combine

@MainActor
final class RecipeViewModel: ObservableObject {
    
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: String? = nil
    @Published var dailyTip: Recipe?
    
    var filteredRecipes: [Recipe] {
        guard let selectedCategory else {
            return recipes
        }
        
        return recipes.filter { recipe in
            recipe.category == selectedCategory
        }
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
    
    func clearCategory() {
        selectedCategory = nil
    }
    
    func loadRecipes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            recipes = try await APIService.shared.fetchRecipes()
            dailyTip = recipes.randomElement()
        } catch {
            errorMessage = "Nepodařilo se načíst recepty."
            print("Chyba při načítání receptů:", error)
        }
        
        isLoading = false
    }
    func loadRecipesIfNeeded() async {
        if isLoading || !recipes.isEmpty {
            return
        }

        await loadRecipes()
    }
}
