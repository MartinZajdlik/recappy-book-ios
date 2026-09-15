import Foundation

struct BlockedUser: Identifiable, Codable, Hashable {
    let id: Int64
    let username: String
}
