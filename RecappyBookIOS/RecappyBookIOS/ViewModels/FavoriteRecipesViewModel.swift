import Foundation
import Combine

@MainActor
final class FavoriteRecipesViewModel: ObservableObject {

    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: .userDidBlockAuthor)
            .sink { [weak self] notification in
                guard let authorId = notification.userInfo?["authorId"] as? Int64 else { return }
                self?.recipes.removeAll { $0.authorId == authorId }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .userDidUnblockAuthor)
            .sink { [weak self] _ in
                Task { await self?.loadRecipes() }
            }
            .store(in: &cancellables)
    }

    func loadRecipes() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            recipes = try await APIService.shared.fetchFavoriteRecipes()
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

    /// Přepnutí z detailu receptu. Recept může být v seznamu, nebo už z něj byl
    /// odebrán (a uživatel ho chce vrátit), proto se po změně seznam načte znovu.
    func toggleFavoriteFromDetail(for recipe: Recipe) async -> Bool? {
        let wasFavorite = recipes.contains { $0.id == recipe.id }

        do {
            try await APIService.shared.toggleFavorite(recipeId: recipe.id)
            await loadRecipes()
            return !wasFavorite
        } catch {
            return nil
        }
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
