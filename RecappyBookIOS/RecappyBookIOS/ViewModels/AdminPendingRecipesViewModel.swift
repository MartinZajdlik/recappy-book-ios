import Foundation
import Combine

@MainActor
final class AdminPendingRecipesViewModel: ObservableObject {

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
            recipes = try await APIService.shared.fetchPendingRecipes()
        } catch {
            errorMessage = error.localizedDescription
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
            errorMessage = error.localizedDescription
        }
    }

    func approve(_ recipe: Recipe) async {
        do {
            try await APIService.shared.approveRecipe(recipeId: recipe.id)
            await loadRecipes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reject(_ recipe: Recipe) async {
        do {
            try await APIService.shared.rejectRecipe(recipeId: recipe.id)
            await loadRecipes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
