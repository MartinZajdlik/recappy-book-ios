import Foundation

struct Recipe: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let imageUrl: String?
}
