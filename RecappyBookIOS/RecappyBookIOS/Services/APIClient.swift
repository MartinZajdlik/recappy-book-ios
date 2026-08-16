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

    /// Prodlevy mezi automatickými pokusy o zopakování požadavku po síťové chybě
    /// (v sekundách). Render free tier umí probouzet se ze spánku desítky sekund,
    /// takže součet prodlev musí pokrýt i delší cold start.
    private let networkRetryDelaysSeconds: [UInt64] = [5, 10, 15]

    /// Provede request; pokud dostane 401 a je k dispozici refresh token, tiše obnoví
    /// access token a request jednou zopakuje. Díky tomu appka nenutí uživatele k novému
    /// přihlášení jen kvůli tomu, že access token mezitím vypršel.
    ///
    /// Síťové chyby (např. odpověď bez HTTPURLResponse, timeout, ztráta spojení) se
    /// navíc automaticky zkouší zopakovat až 3x s rostoucí prodlevou (5s, 10s, 15s),
    /// aby appka ustála i pomalejší probouzení Render backendu ze spánku. Tahle logika
    /// se netýká 401/refresh tokenu výše, ta zůstává beze změny.
    func send(_ request: URLRequest, retryOnAuthFailure: Bool = true) async throws -> (Data, HTTPURLResponse) {
        let (data, httpResponse) = try await sendWithNetworkRetry(request)

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

        return try await sendWithNetworkRetry(retriedRequest)
    }

    private func sendWithNetworkRetry(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var lastError: Error = URLError(.badServerResponse)

        for attempt in 0...networkRetryDelaysSeconds.count {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                await setWakingServer(false)
                return (data, httpResponse)
            } catch {
                lastError = error

                guard attempt < networkRetryDelaysSeconds.count,
                      Self.isRetryableNetworkError(error) else {
                    await setWakingServer(false)
                    throw error
                }

                await setWakingServer(true)
                try? await Task.sleep(nanoseconds: networkRetryDelaysSeconds[attempt] * 1_000_000_000)
            }
        }

        await setWakingServer(false)
        throw lastError
    }

    @MainActor
    private func setWakingServer(_ isWaking: Bool) {
        NetworkWakeState.shared.isWakingServer = isWaking
    }

    private static func isRetryableNetworkError(_ error: Error) -> Bool {
        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else { return false }

        let retryableCodes: Set<Int> = [
            URLError.badServerResponse.rawValue,
            URLError.timedOut.rawValue,
            URLError.networkConnectionLost.rawValue
        ]
        return retryableCodes.contains(nsError.code)
    }

    /// Sdílená detekce skutečné autentizační chyby (401/403 z backendu), tedy že token
    /// je opravdu neplatný/vypršel – ne že selhalo síťové/serverové volání (viz `send`
    /// výše, kde na 401 nejdřív zkusíme refresh tokenu; teprve neúspěšný refresh sem
    /// propadne jako trvalá 401). Použij tuhle funkci všude, kde je potřeba rozlišit
    /// "neplatný token" od "výpadek/timeout serveru", ať se logika nedubluje.
    static func isAuthError(_ error: Error) -> Bool {
        let nsError = error as NSError
        guard nsError.domain != NSURLErrorDomain else { return false }
        return nsError.code == 401 || nsError.code == 403
    }
}
