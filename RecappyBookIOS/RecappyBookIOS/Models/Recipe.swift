import SwiftUI

struct Recipe: Identifiable, Codable {
    let id: Int64
    let title: String
    let ingredients: String?
    let instructions: String?
    let category: String?
    let imageUrl: String?
}
