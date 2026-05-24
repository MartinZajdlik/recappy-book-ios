import Foundation
import Combine

@MainActor
final class AdminUsersViewModel: ObservableObject {
    
    @Published var users: [AdminUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            users = try await APIService.shared.fetchAdminUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteUser(_ user: AdminUser) async {
        do {
            try await APIService.shared.deleteUser(userId: user.id)
            await loadUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func changeRole(for user: AdminUser, to role: String) async {
        do {
            try await APIService.shared.changeUserRole(
                userId: user.id,
                role: role
            )
            await loadUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
