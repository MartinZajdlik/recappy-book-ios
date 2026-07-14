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
              httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func createRecipe(
        title: String,
        category: String,
        ingredients: String,
        instructions: String,
        imageData: Data?
        
    ) async throws {
        
        let boundary = UUID().uuidString
        
        var request = try APIClient.shared.makeRequest(
            path: "/recepty",
            method: "POST",
            requiresAuth: true
        )
        
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        
        request.httpBody = makeRecipeMultipartBody(
            boundary: boundary,
            title: title,
            category: category,
            ingredients: ingredients,
            instructions: instructions,
            imageData: imageData
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: "Server vrátil chybu \(httpResponse.statusCode)"
                ]
            )
        }
    }

    func updateRecipe(
        id: Int64,
        title: String,
        category: String,
        ingredients: String,
        instructions: String,
        imageData: Data?
    ) async throws -> Recipe {
        
        let boundary = UUID().uuidString
        
        var request = try APIClient.shared.makeRequest(
            path: "/recepty/\(id)",
            method: "PUT",
            requiresAuth: true
        )
        
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        
        request.httpBody = makeRecipeMultipartBody(
            boundary: boundary,
            title: title,
            category: category,
            ingredients: ingredients,
            instructions: instructions,
            imageData: imageData
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(Recipe.self, from: data)
    }

    private func makeRecipeMultipartBody(
        boundary: String,
        title: String,
        category: String,
        ingredients: String,
        instructions: String,
        imageData: Data?
    ) -> Data {
        
        var data = Data()
        
        func appendField(name: String, value: String) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        appendField(name: "title", value: title)
        appendField(name: "category", value: category)
        appendField(name: "ingredients", value: ingredients)
        appendField(name: "instructions", value: instructions)
        
        if let imageData {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"image\"; filename=\"recipe.jpg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
            data.append("\r\n".data(using: .utf8)!)
        }
        
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data
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
    
    func fetchMyRecipes() async throws -> [Recipe] {

        var request = try APIClient.shared.makeRequest(
            path: "/recepty/my",
            requiresAuth: true
        )

        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Recipe].self, from: data)
    }
    func fetchFavoriteRecipes() async throws -> [Recipe] {
        let request = try APIClient.shared.makeRequest(
            path: "/recepty/favorites",
            method: "GET",
            requiresAuth: true
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Recipe].self, from: data)
    }

    func toggleFavorite(recipeId: Int64) async throws {
        let request = try APIClient.shared.makeRequest(
            path: "/recepty/\(recipeId)/favorite",
            method: "POST",
            requiresAuth: true
        )

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    func fetchAllRecipesForAdmin() async throws -> [Recipe] {

        let request = try APIClient.shared.makeRequest(
            path: "/admin/recepty",
            method: "GET",
            requiresAuth: true
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Recipe].self, from: data)
    }

    func fetchPendingRecipes() async throws -> [Recipe] {

        let request = try APIClient.shared.makeRequest(
            path: "/admin/recepty/pending",
            method: "GET",
            requiresAuth: true
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Recipe].self, from: data)
    }

    func approveRecipe(recipeId: Int64) async throws {
        let request = try APIClient.shared.makeRequest(
            path: "/admin/recepty/\(recipeId)/approve",
            method: "PATCH",
            requiresAuth: true
        )

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    func rejectRecipe(recipeId: Int64) async throws {
        let request = try APIClient.shared.makeRequest(
            path: "/admin/recepty/\(recipeId)/reject",
            method: "PATCH",
            requiresAuth: true
        )

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

}
