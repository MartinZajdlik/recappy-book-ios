import Foundation

final class APIClient {
    
    static let shared = APIClient()
    
    private init() {}
    
    let baseURL = "https://recappy-book.onrender.com"
    
    func makeRequest(
        path: String,
        method: String = "GET",
        requiresAuth: Bool = false,
        optionalAuth: Bool = false
    ) throws -> URLRequest {

        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if requiresAuth {
            guard let token = KeychainService.shared.getToken() else {
                throw NSError(
                    domain: "",
                    code: 401,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Nejsi přihlášen."
                    ]
                )
            }

            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if optionalAuth, let token = KeychainService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    /// Provede request; pokud dostane 401 a je k dispozici refresh token, tiše obnoví
    /// access token a request jednou zopakuje. Díky tomu appka nenutí uživatele k novému
    /// přihlášení jen kvůli tomu, že access token mezitím vypršel.
    func send(_ request: URLRequest, retryOnAuthFailure: Bool = true) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 401,
              retryOnAuthFailure,
              request.value(forHTTPHeaderField: "Authorization") != nil,
              KeychainService.shared.getRefreshToken() != nil else {
            return (data, httpResponse)
        }

        guard let newAccessToken = try? await AuthService.shared.refreshAccessToken() else {
            return (data, httpResponse)
        }

        var retriedRequest = request
        retriedRequest.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")

        let (retriedData, retriedResponse) = try await URLSession.shared.data(for: retriedRequest)
        guard let retriedHttpResponse = retriedResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        return (retriedData, retriedHttpResponse)
    }
}
