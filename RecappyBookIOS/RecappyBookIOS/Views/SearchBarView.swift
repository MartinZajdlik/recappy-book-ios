import SwiftUI

/// Vyhledávací pole ve stylu appky (tmavá karta, lupa, křížek na smazání).
struct SearchBarView: View {

    @Binding var text: String
    /// Fokus řídí rodič, aby ho mohl zrušit (např. při klepnutí na kategorii).
    var isFocused: FocusState<Bool>.Binding
    var placeholder: String = "Hledat recept nebo surovinu"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(isFocused.wrappedValue ? AppTheme.green : AppTheme.mutedText)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder).foregroundStyle(AppTheme.mutedText)
            )
            .foregroundStyle(AppTheme.text)
            .tint(AppTheme.green)
            .focused(isFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.mutedText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Smazat hledání")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused.wrappedValue ? AppTheme.green.opacity(0.6) : Color.clear, lineWidth: 1)
        )
    }
}

private struct SearchBarPreview: View {
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        SearchBarView(text: $text, isFocused: $isFocused)
            .padding()
            .background(AppTheme.background)
    }
}

#Preview {
    SearchBarPreview()
}
