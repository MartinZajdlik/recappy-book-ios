import Foundation
import Combine

/// Doplňující údaje pro uživatelské menu (počty, stav receptů, dnešní jídelníček).
/// Používá jen existující endpointy – žádná změna backendu. Chyby se tiše
/// ignorují: menu musí fungovat i bez těchto údajů (např. když se server probouzí).
@MainActor
final class UserMenuViewModel: ObservableObject {

    @Published private(set) var myRecipesCount: Int?
    @Published private(set) var pendingCount = 0
    @Published private(set) var rejectedCount = 0
    @Published private(set) var favoritesCount: Int?
    @Published private(set) var todayMeal: String?

    /// Spustí tři nezávislá načtení najednou. Každý Task dědí MainActor, takže
    /// se nepřekračují hranice izolace; souběžně běží díky čekání na síť.
    func load(includeFavorites: Bool) {
        Task { await loadMyRecipes() }
        Task { await loadMealPlan() }
        if includeFavorites {
            Task { await loadFavorites() }
        }
    }

    private func loadMyRecipes() async {
        guard let myRecipes = try? await APIService.shared.fetchMyRecipes() else { return }
        myRecipesCount = myRecipes.count
        pendingCount = myRecipes.filter { $0.status == .pending }.count
        rejectedCount = myRecipes.filter { $0.status == .rejected }.count
    }

    private func loadFavorites() async {
        guard let favorites = try? await APIService.shared.fetchFavoriteRecipes() else { return }
        favoritesCount = favorites.count
    }

    private func loadMealPlan() async {
        guard let mealPlan = try? await APIService.shared.fetchMealPlan() else { return }
        todayMeal = Self.todayMeal(from: mealPlan)
    }

    /// Jídelníček čísluje dny 1 = pondělí … 7 = neděle, Calendar 1 = neděle … 7 = sobota.
    private static func todayMeal(from entries: [MealPlanEntry]) -> String? {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let dayOfWeek = ((weekday + 5) % 7) + 1

        guard let entry = entries.first(where: { $0.dayOfWeek == dayOfWeek }) else {
            return nil
        }

        // Nejzajímavější je oběd, pak večeře, pak snídaně.
        let candidates = [entry.lunch, entry.dinner, entry.breakfast]
        return candidates
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
            .map { $0.components(separatedBy: .newlines).first ?? $0 }
    }
}
