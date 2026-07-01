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
            errorMessage = error.localizedDescription
        }
    }
}
