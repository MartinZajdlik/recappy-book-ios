import Foundation

final class APIClient {
    
    static let shared = APIClient()
    
    private init() {}
    
    let baseURL = "https://recappy-book.onrender.com"
    
    func makeRequest(
        path: String,
        method: String = "GET",
        requiresAuth: Bool = false
    ) throws -> URLRequest {
        
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if requiresAuth {
            guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
                throw NSError(
                    domain: "",
                    code: 401,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Nejsi přihlášen."
                    ]
                )
            }
            
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
