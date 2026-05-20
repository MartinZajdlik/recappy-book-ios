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
}
