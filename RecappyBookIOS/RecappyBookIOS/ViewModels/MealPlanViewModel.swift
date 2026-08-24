import Foundation
import Combine

@MainActor
final class MealPlanViewModel: ObservableObject {

    @Published var entries: [MealPlanEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadMealPlan() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            entries = try await APIService.shared.fetchMealPlan()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    func loadMealPlanIfNeeded() async {
        if isLoading || !entries.isEmpty {
            return
        }

        await loadMealPlan()
    }

    func entry(forDay dayOfWeek: Int) -> MealPlanEntry {
        entries.first(where: { $0.dayOfWeek == dayOfWeek })
            ?? MealPlanEntry(dayOfWeek: dayOfWeek, breakfast: nil, snack1: nil, lunch: nil, snack2: nil, dinner: nil)
    }

    @discardableResult
    func saveDay(
        dayOfWeek: Int,
        breakfast: String?,
        snack1: String?,
        lunch: String?,
        snack2: String?,
        dinner: String?
    ) async -> Bool {
        do {
            let updated = try await APIService.shared.updateMealPlanDay(
                dayOfWeek: dayOfWeek,
                entry: MealPlanUpdateRequest(
                    breakfast: breakfast,
                    snack1: snack1,
                    lunch: lunch,
                    snack2: snack2,
                    dinner: dinner
                )
            )

            if let index = entries.firstIndex(where: { $0.dayOfWeek == dayOfWeek }) {
                entries[index] = updated
            } else {
                entries.append(updated)
            }

            return true
        } catch {
            errorMessage = error.userFacingMessage
            return false
        }
    }
}
