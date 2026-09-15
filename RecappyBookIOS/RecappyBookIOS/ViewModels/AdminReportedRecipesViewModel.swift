import Foundation
import Combine

@MainActor
final class AdminReportedRecipesViewModel: ObservableObject {

    @Published var reports: [ReportedRecipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadReports() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            reports = try await APIService.shared.fetchReportedRecipes()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    func loadReportsIfNeeded() async {
        if isLoading || !reports.isEmpty {
            return
        }

        await loadReports()
    }

    // "Ponechat" – nahlášení se označí za vyřízené, recept zůstává veřejný.
    func dismiss(_ report: ReportedRecipe) async {
        do {
            try await APIService.shared.dismissRecipeReports(recipeId: report.id)
            await loadReports()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    // "Smazat" – recept zmizí úplně; endpoint sám uklidí i nahlášení.
    func delete(_ report: ReportedRecipe) async {
        do {
            try await APIService.shared.deleteRecipe(recipeId: report.id)
            await loadReports()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}
