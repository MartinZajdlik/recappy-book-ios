import Foundation
import Combine

/// Sdílený stav, který appka nastaví, když `APIClient` právě automaticky
/// zkouší požadavek znovu kvůli síťové chybě (typicky Render free tier,
/// který se probouzí ze spánku). Views na to mohou navázat a místo
/// prázdného spinneru zobrazit srozumitelný text.
final class NetworkWakeState: ObservableObject {

    static let shared = NetworkWakeState()

    @Published var isWakingServer = false

    private init() {}
}

private let networkErrorCodes: Set<Int> = [
    URLError.badServerResponse.rawValue,
    URLError.timedOut.rawValue,
    URLError.networkConnectionLost.rawValue,
    URLError.notConnectedToInternet.rawValue,
    URLError.cannotConnectToHost.rawValue,
    URLError.cannotFindHost.rawValue,
    URLError.dnsLookupFailed.rawValue
]

extension Error {

    /// Uživatelsky přívětivá česká hláška pro chyby zobrazované přímo v UI.
    /// Síťové/timeout chyby (typicky probouzení Render backendu ze spánku)
    /// se namapují na srozumitelný text, ostatní chyby si ponechají svůj
    /// `localizedDescription` (např. hlášky z API/`NSLocalizedDescriptionKey`).
    var userFacingMessage: String {
        let nsError = self as NSError

        guard nsError.domain == NSURLErrorDomain,
              networkErrorCodes.contains(nsError.code) else {
            return localizedDescription
        }

        return "Server se probouzí, zkus to prosím za chvíli znovu."
    }
}
