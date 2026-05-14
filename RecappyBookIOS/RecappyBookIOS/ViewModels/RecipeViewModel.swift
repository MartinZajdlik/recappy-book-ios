import SwiftUI
import Combine

@MainActor
final class RecipeViewModel: ObservableObject {
    
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadRecipes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            recipes = try await APIService.shared.fetchRecipes()
        } catch {
            errorMessage = "Nepodařilo se načíst recepty."
            print("Chyba při načítání receptů:", error)
        }
        
        isLoading = false
    }
}
