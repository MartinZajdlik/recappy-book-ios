import SwiftUI

/// Loading indikátor, který během automatických retry pokusů `APIClient`
/// (probouzení Render backendu ze spánku) přepne text na srozumitelnou hlášku
/// místo běžného "Načítám...".
struct LoadingStateView: View {

    @ObservedObject private var networkWakeState = NetworkWakeState.shared

    let defaultMessage: String

    var body: some View {
        ProgressView(networkWakeState.isWakingServer ? "Probouzím server…" : defaultMessage)
            .foregroundStyle(AppTheme.text)
    }
}

/// Chybová hláška s tlačítkem pro opakování požadavku, pro případ že by
/// automatické retry pokusy v `APIClient` nestačily.
struct ErrorRetryView: View {

    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(message)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)

            Button("Zkusit znovu", action: onRetry)
                .buttonStyle(.bordered)
                .tint(AppTheme.green)
        }
        .padding(.horizontal)
    }
}
