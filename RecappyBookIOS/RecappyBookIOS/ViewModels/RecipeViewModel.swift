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

        NotificationCenter.default.publisher(for: .userDidUnblockAuthor)
            .sink { [weak self] _ in
                Task { await self?.loadRecipes() }
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
    /// Tiché obnovení (stažení dolů / návrat do aplikace): bez načítací obrazovky
    /// a se zachováním dnešního tipu, pokud recept pořád existuje.
    func refresh() async {
        do {
            let fresh = try await APIService.shared.fetchRecipes()
            recipes = fresh
            if let tipId = dailyTip?.id, let updatedTip = fresh.first(where: { $0.id == tipId }) {
                dailyTip = updatedTip
            } else {
                dailyTip = fresh.randomElement()
            }
            errorMessage = nil
        } catch {
            // Při chybě necháme zobrazená stávající data.
            if recipes.isEmpty {
                errorMessage = "Nepodařilo se načíst recepty."
            }
            print("Chyba při obnovení receptů:", error)
        }
    }

    func loadRecipesIfNeeded() async {
        if isLoading || !recipes.isEmpty {
            return
        }

        await loadRecipes()
    }
    /// Vrací nový stav oblíbenosti, nebo `nil`, když se změna nepovedla.
    @discardableResult
    func toggleFavorite(for recipe: Recipe) async -> Bool? {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else {
            return nil
        }

        recipes[index].favorite.toggle()
        let newValue = recipes[index].favorite

        do {
            try await APIService.shared.toggleFavorite(recipeId: recipe.id)

            if dailyTip?.id == recipe.id {
                dailyTip?.favorite = newValue
            }
            return newValue
        } catch {
            if let i = recipes.firstIndex(where: { $0.id == recipe.id }) {
                recipes[i].favorite = !newValue
            }
            errorMessage = "Nepodařilo se upravit oblíbený recept."
            print("Chyba při změně oblíbeného receptu:", error)
            return nil
        }
    }
}
