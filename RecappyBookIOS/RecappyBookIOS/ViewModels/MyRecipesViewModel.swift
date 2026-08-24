import Foundation
import Combine

@MainActor
final class MyRecipesViewModel: ObservableObject {

    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadRecipes() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            recipes = try await APIService.shared.fetchMyRecipes()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
    func loadRecipesIfNeeded() async {
        if isLoading || !recipes.isEmpty {
            return
        }

        await loadRecipes()
    }

    func deleteRecipe(_ recipe: Recipe) async {
        do {
            try await APIService.shared.deleteRecipe(recipeId: recipe.id)
            await loadRecipes()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}
