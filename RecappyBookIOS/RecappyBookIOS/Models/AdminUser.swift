import Foundation

struct AdminUser: Identifiable, Codable {
    let id: Int64
    let username: String
    let email: String
    let role: String
}
