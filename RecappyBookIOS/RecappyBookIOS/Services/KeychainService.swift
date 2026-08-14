import Foundation
import Security

final class KeychainService {
    
    static let shared = KeychainService()
    
    private init() {}
    
    private let service = "cz.martinzajdlik.recappybook"
    private let tokenKey = "jwtToken"
    private let refreshTokenKey = "jwtRefreshToken"

    func saveToken(_ token: String) {
        save(token, forKey: tokenKey)
    }

    func getToken() -> String? {
        get(forKey: tokenKey)
    }

    func deleteToken() {
        delete(forKey: tokenKey)
    }

    func saveRefreshToken(_ token: String) {
        save(token, forKey: refreshTokenKey)
    }

    func getRefreshToken() -> String? {
        get(forKey: refreshTokenKey)
    }

    func deleteRefreshToken() {
        delete(forKey: refreshTokenKey)
    }

    func clearSession() {
        deleteToken()
        deleteRefreshToken()
    }

    private func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }

        delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
