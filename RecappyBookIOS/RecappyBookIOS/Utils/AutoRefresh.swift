import SwiftUI

/// Obnovení dat stažením seznamu dolů (pull-to-refresh) a automaticky
/// po návratu do aplikace (z pozadí / z jiné aplikace).
private struct AutoRefreshModifier: ViewModifier {

    @Environment(\.scenePhase) private var scenePhase
    @State private var wasInBackground = false
    let action: () async -> Void

    func body(content: Content) -> some View {
        content
            .refreshable {
                await action()
            }
            .onChange(of: scenePhase) { _, newPhase in
                // Přechod pozadí → aktivní vede přes .inactive, proto si pamatujeme,
                // že aplikace byla na pozadí. Samotné stažení ovládacího centra
                // (jen .inactive) tak obnovení nespustí.
                if newPhase == .background {
                    wasInBackground = true
                } else if newPhase == .active && wasInBackground {
                    wasInBackground = false
                    Task {
                        await action()
                    }
                }
            }
    }
}

extension View {
    /// Přidá obnovení stažením dolů a obnovení po návratu do aplikace.
    /// Připojit přímo za `ScrollView` (před `.navigationDestination`),
    /// aby se obnovení nepřeneslo do detailů otevřených z této obrazovky.
    func autoRefresh(_ action: @escaping () async -> Void) -> some View {
        modifier(AutoRefreshModifier(action: action))
    }
}
