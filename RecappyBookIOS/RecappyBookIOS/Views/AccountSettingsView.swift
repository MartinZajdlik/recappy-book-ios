import SwiftUI

/// Nastavení účtu – zatím jen přehled a smazání profilu. Smazání musí zůstat
/// v appce dohledatelné (požadavek App Store), jen už není na hlavní obrazovce menu.
/// Zobrazuje se přímo uvnitř UserMenuView (bez navigace), proto má vlastní „Zpět“.
struct AccountSettingsView: View {

    let username: String
    let onBack: () -> Void
    let onDeleteProfile: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {

            HStack {
                Button {
                    onBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Zpět")
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.green)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.top, 20)

            Text("Nastavení účtu")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.text)

            VStack(alignment: .leading, spacing: 8) {
                Text("PŘIHLÁŠEN JAKO")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedText)
                    .padding(.leading, 6)

                HStack {
                    Text(username)
                        .font(.body)
                        .foregroundStyle(AppTheme.text)
                    Spacer()
                }
                .padding(14)
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            VStack(alignment: .leading, spacing: 8) {
                Button(role: .destructive) {
                    onDeleteProfile()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "trash.fill")
                        Text("Smazat profil")
                        Spacer()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.iconRed)
                    .padding(14)
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Text("Smaže tvůj účet, všechny tvoje recepty, oblíbené a jídelníček. Tuto akci nelze vrátit.")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.mutedText)
                    .padding(.horizontal, 6)
            }
        }
        .padding()
    }
}

#Preview {
    AccountSettingsView(username: "user", onBack: {}, onDeleteProfile: {})
        .background(AppTheme.background)
}
