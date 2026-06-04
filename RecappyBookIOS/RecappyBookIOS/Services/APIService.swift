import Foundation

final class APIService {
    
    static let shared = APIService()
    
    private init() {}
    
    func fetchRecipes() async throws -> [Recipe] {
        
        let request = try APIClient.shared.makeRequest(
            path: "/recepty",
            method: "GET",
            requiresAuth: false
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Recipe].self, from: data)
    }


    func deleteRecipe(recipeId: Int64) async throws {
        
        let request = try APIClient.shared.makeRequest(
            path: "/recepty/\(recipeId)",
            method: "DELETE",
            requiresAuth: true
        )
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    

    func fetchAdminUsers() async throws -> [AdminUser] {
        
        let request = try APIClient.shared.makeRequest(
            path: "/admin/users",
            method: "GET",
            requiresAuth: true
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([AdminUser].self, from: data)
    }

    func changeUserRole(userId: Int64, role: String) async throws {
        
        let request = try APIClient.shared.makeRequest(
            path: "/admin/users/\(userId)/role?role=\(role)",
            method: "PUT",
            requiresAuth: true
        )
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    func deleteUser(userId: Int64) async throws {
        
        let request = try APIClient.shared.makeRequest(
            path: "/admin/users/\(userId)",
            method: "DELETE",
            requiresAuth: true
        )
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
}
