import SwiftUI

final class APIService {
    
    static let shared = APIService()
    
    private init() {}
    
    private let baseURL = "https://recappy-book.onrender.com"
    
    func fetchRecipes() async throws -> [Recipe] {
        guard let url = URL(string: "\(baseURL)/recepty") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let recipes = try JSONDecoder().decode([Recipe].self, from: data)
        return recipes
        
    }

}
