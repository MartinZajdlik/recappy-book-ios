import Foundation
import Combine

@MainActor
final class AdminRecipesViewModel: ObservableObject {
    
    @Published var recipes: [Recipe] = []
    @Published var selectedCategory: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let categories = ["Polévky", "Hlavní jídla", "Dezerty", "Snídaně", "Ostatní"]
    
    var filteredRecipes: [Recipe] {
        guard let selectedCategory else {
            return recipes
        }
        
        return recipes.filter { $0.category == selectedCategory }
    }
    
    func loadRecipes() async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            recipes = try await APIService.shared.fetchRecipes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
    
    func clearCategory() {
        selectedCategory = nil
    }
}
