import Foundation

struct MealPlanEntry: Codable, Identifiable {
    let dayOfWeek: Int
    let breakfast: String?
    let snack1: String?
    let lunch: String?
    let snack2: String?
    let dinner: String?

    var id: Int { dayOfWeek }
}

struct MealPlanUpdateRequest: Codable {
    let breakfast: String?
    let snack1: String?
    let lunch: String?
    let snack2: String?
    let dinner: String?
}
