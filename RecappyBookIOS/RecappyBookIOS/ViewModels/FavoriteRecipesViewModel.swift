import Foundation
import Combine

@MainActor
final class FavoriteRecipesViewModel: ObservableObject {

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
            recipes = try await APIService.shared.fetchFavoriteRecipes()
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

    func toggleFavorite(for recipe: Recipe) async {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else {
            return
        }

        let removed = recipes.remove(at: index)

        do {
            try await APIService.shared.toggleFavorite(recipeId: recipe.id)
        } catch {
            recipes.insert(removed, at: index)
            errorMessage = "Nepodařilo se upravit oblíbený recept."
        }
    }
}
