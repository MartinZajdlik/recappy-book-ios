import SwiftUI

/// Nastavení účtu – zatím jen přehled a smazání profilu. Smazání musí zůstat
/// v appce dohledatelné (požadavek App Store), jen už není na hlavní obrazovce menu.
struct AccountSettingsView: View {

    let username: String
    let onDeleteProfile: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

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
        .background(AppTheme.background)
        .navigationTitle("Nastavení účtu")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        AccountSettingsView(username: "user") {}
    }
}
