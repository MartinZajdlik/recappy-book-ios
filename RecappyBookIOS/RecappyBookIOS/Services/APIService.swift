import Foundation

final class APIService {

    static let shared = APIService()

    private init() {}

    /// Provede GET na `path` a rovnou dekóduje JSON odpověď; sdílí stejnou
    /// kontrolu stavového kódu (200) napříč všemi jednoduchými fetch endpointy.
    private func decodedGET<T: Decodable>(
        _ path: String,
        requiresAuth: Bool = true,
        optionalAuth: Bool = false
    ) async throws -> T {

        let request = try APIClient.shared.makeRequest(
            path: path,
            method: "GET",
            requiresAuth: requiresAuth,
            optionalAuth: optionalAuth
        )

        let (data, response) = try await APIClient.shared.send(request)

        guard response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Provede akci bez těla odpovědi (delete/toggle/approve/…) a ověří, že
    /// server vrátil jeden z očekávaných stavových kódů.
    private func performAction(
        _ path: String,
        method: String,
        acceptedStatusCodes: Set<Int> = [200]
    ) async throws {

        let request = try APIClient.shared.makeRequest(
            path: path,
            method: method,
            requiresAuth: true
        )

        let (_, response) = try await APIClient.shared.send(request)

        guard acceptedStatusCodes.contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    func fetchRecipes() async throws -> [Recipe] {
        try await decodedGET("/recepty", requiresAuth: false, optionalAuth: true)
    }

    func deleteRecipe(recipeId: Int64) async throws {
        try await performAction("/recepty/\(recipeId)", method: "DELETE", acceptedStatusCodes: [200, 204])
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

        let (_, response) = try await APIClient.shared.send(request)

        guard response.statusCode == 200 || response.statusCode == 201 else {
            throw NSError(
                domain: "",
                code: response.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: "Server vrátil chybu \(response.statusCode)"
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

        let (data, response) = try await APIClient.shared.send(request)

        guard response.statusCode == 200 else {
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
        try await decodedGET("/admin/users")
    }

    func changeUserRole(userId: Int64, role: String) async throws {
        try await performAction("/admin/users/\(userId)/role?role=\(role)", method: "PUT")
    }

    func deleteUser(userId: Int64) async throws {
        try await performAction("/admin/users/\(userId)", method: "DELETE")
    }

    func fetchMyRecipes() async throws -> [Recipe] {
        try await decodedGET("/recepty/my")
    }

    func fetchFavoriteRecipes() async throws -> [Recipe] {
        try await decodedGET("/recepty/favorites")
    }

    func toggleFavorite(recipeId: Int64) async throws {
        try await performAction("/recepty/\(recipeId)/favorite", method: "POST")
    }

    func fetchAllRecipesForAdmin() async throws -> [Recipe] {
        try await decodedGET("/admin/recepty")
    }

    func fetchPendingRecipes() async throws -> [Recipe] {
        try await decodedGET("/admin/recepty/pending")
    }

    func fetchPendingRecipesCount() async throws -> Int {
        try await decodedGET("/admin/recepty/pending/count")
    }

    func approveRecipe(recipeId: Int64) async throws {
        try await performAction("/admin/recepty/\(recipeId)/approve", method: "PATCH")
    }

    func rejectRecipe(recipeId: Int64) async throws {
        try await performAction("/admin/recepty/\(recipeId)/reject", method: "PATCH")
    }

    // MARK: - MEAL PLAN

    func fetchMealPlan() async throws -> [MealPlanEntry] {
        try await decodedGET("/jidelnicek")
    }

    func updateMealPlanDay(dayOfWeek: Int, entry: MealPlanUpdateRequest) async throws -> MealPlanEntry {
        var request = try APIClient.shared.makeRequest(
            path: "/jidelnicek/\(dayOfWeek)",
            method: "PUT",
            requiresAuth: true
        )

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(entry)

        let (data, response) = try await APIClient.shared.send(request)

        guard response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(MealPlanEntry.self, from: data)
    }

}
