import Foundation

/// Hledání receptů přímo v telefonu (všechny schválené recepty už appka má načtené).
/// - nezáleží na velikosti písmen ani diakritice („gulas“ najde „Guláš“),
/// - hledá v názvu i surovinách,
/// - víc slov = všechna musí v receptu být, v libovolném pořadí,
/// - recepty se shodou v názvu jdou první.
enum RecipeSearch {

    private static let czechLocale = Locale(identifier: "cs_CZ")

    static func normalize(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: czechLocale)
    }

    static func tokens(from query: String) -> [String] {
        normalize(query)
            .split(whereSeparator: { $0.isWhitespace || $0 == "," })
            .map(String.init)
    }

    static func filter(_ recipes: [Recipe], query: String) -> [Recipe] {
        let queryTokens = tokens(from: query)
        guard !queryTokens.isEmpty else { return recipes }

        let scored: [(recipe: Recipe, titleHits: Int, index: Int)] = recipes.enumerated().compactMap { index, recipe in
            let title = normalize(recipe.title)
            let ingredients = normalize(recipe.ingredients ?? "")

            var titleHits = 0
            for token in queryTokens {
                if title.contains(token) {
                    titleHits += 1
                } else if !ingredients.contains(token) {
                    return nil
                }
            }
            return (recipe, titleHits, index)
        }

        return scored
            .sorted { lhs, rhs in
                lhs.titleHits != rhs.titleHits ? lhs.titleHits > rhs.titleHits : lhs.index < rhs.index
            }
            .map(\.recipe)
    }
}
