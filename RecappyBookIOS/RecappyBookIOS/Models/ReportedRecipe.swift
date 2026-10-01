import Foundation

/// Shrnutí pro obrazovku "Nahlášené recepty" v adminu – recept + kolikrát
/// byl nahlášen. Vrací ho AdminRecipeReportController (/admin/recepty/reports).
struct ReportedRecipe: Identifiable, Codable, Hashable {
    let id: Int64
    let title: String
    let ingredients: String?
    let instructions: String?
    let category: String?
    let imageUrl: String?
    let authorUsername: String?
    let reportCount: Int
    /// Kdo a kdy recept nahlásil. Nepovinné – starší backend pole neposílá.
    let reporters: [Reporter]?

    struct Reporter: Codable, Hashable {
        let username: String
        /// Epoch milisekundy z backendu.
        let reportedAt: Int64

        var date: Date {
            Date(timeIntervalSince1970: TimeInterval(reportedAt) / 1000)
        }
    }

    /// Aby šel snadno zobrazit ve stávající AdminRecipeCardView (očekává Recipe).
    var asRecipe: Recipe {
        Recipe(
            id: id,
            title: title,
            ingredients: ingredients,
            instructions: instructions,
            category: category,
            imageUrl: imageUrl,
            authorUsername: authorUsername,
            favorite: false,
            status: .approved
        )
    }
}
