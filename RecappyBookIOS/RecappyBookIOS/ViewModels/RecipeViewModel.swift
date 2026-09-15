import SwiftUI
import Combine

@MainActor
final class RecipeViewModel: ObservableObject {
    
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: String? = nil
    @Published var dailyTip: Recipe?

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: .userDidBlockAuthor)
            .sink { [weak self] notification in
                guard let authorId = notification.userInfo?["authorId"] as? Int64 else { return }
                self?.removeRecipes(fromAuthorId: authorId)
            }
            .store(in: &cancellables)
    }

    /// Okamžité (optimistické) odebrání receptů od právě zablokovaného
    /// autora – bez čekání na další fetch/restart appky.
    func removeRecipes(fromAuthorId authorId: Int64) {
        recipes.removeAll { $0.authorId == authorId }
        if dailyTip?.authorId == authorId {
            dailyTip = recipes.randomElement()
        }
    }
    
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
    func toggleFavorite(for recipe: Recipe) async {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else {
            return
        }

        recipes[index].favorite.toggle()

        do {
            try await APIService.shared.toggleFavorite(recipeId: recipe.id)

            if dailyTip?.id == recipe.id {
                dailyTip?.favorite = recipes[index].favorite
            }
        } catch {
            recipes[index].favorite.toggle()
            errorMessage = "Nepodařilo se upravit oblíbený recept."
            print("Chyba při změně oblíbeného receptu:", error)
        }
    }
}
