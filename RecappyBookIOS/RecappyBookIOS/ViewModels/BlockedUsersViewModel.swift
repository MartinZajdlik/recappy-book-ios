import Foundation
import Combine

@MainActor
final class BlockedUsersViewModel: ObservableObject {

    @Published var blockedUsers: [BlockedUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadBlockedUsers() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            blockedUsers = try await APIService.shared.fetchBlockedUsers()
        } catch {
            errorMessage = error.userFacingMessage
        }
    }

    func unblock(_ user: BlockedUser) async {
        do {
            try await APIService.shared.unblockUser(userId: user.id)
            blockedUsers.removeAll { $0.id == user.id }
            NotificationCenter.default.post(
                name: .userDidUnblockAuthor,
                object: nil,
                userInfo: ["authorId": user.id]
            )
        } catch {
            errorMessage = error.userFacingMessage
        }
    }
}
