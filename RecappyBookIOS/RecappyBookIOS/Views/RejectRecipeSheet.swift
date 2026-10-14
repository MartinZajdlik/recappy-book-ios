import SwiftUI

/// Dialog, ve kterém admin při zamítnutí receptu vyplní důvod.
/// Důvod pak autor uvidí u svého receptu a ví, co opravit.
struct RejectRecipeSheet: View {

    let recipe: Recipe
    let onConfirm: (String) async -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var reason = ""
    @State private var isSubmitting = false
    @FocusState private var isReasonFocused: Bool

    /// Musí odpovídat limitu na backendu (AdminRecipeController).
    private let maxLength = 500

    private let presets = [
        "Chybí suroviny nebo postup.",
        "Nevhodná nebo nekvalitní fotka.",
        "Tento recept už v aplikaci je.",
        "Nejde o recept.",
        "Nevhodný obsah."
    ]

    private var trimmedReason: String {
        reason.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text("Zamítnout „\(recipe.title)“")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.text)

                    Text("Napiš autorovi, proč recept neprošel. Uvidí to u svého receptu a může ho opravit a poslat znovu.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedText)

                    Text("Rychlá volba")
                        .font(.headline)
                        .foregroundStyle(AppTheme.green)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(presets, id: \.self) { preset in
                            Button {
                                reason = preset
                            } label: {
                                HStack {
                                    Text(preset)
                                        .foregroundStyle(AppTheme.text)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    if trimmedReason == preset {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(AppTheme.green)
                                    }
                                }
                                .padding(12)
                                .background(AppTheme.categoryCard)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("Důvod")
                        .font(.headline)
                        .foregroundStyle(AppTheme.green)

                    TextEditor(text: $reason)
                        .focused($isReasonFocused)
                        .frame(minHeight: 110)
                        .padding(6)
                        .background(AppTheme.categoryCard)
                        .foregroundStyle(AppTheme.text)
                        .scrollContentBackground(.hidden)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onChange(of: reason) { _, newValue in
                            if newValue.count > maxLength {
                                reason = String(newValue.prefix(maxLength))
                            }
                        }

                    Text("\(reason.count)/\(maxLength)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedText)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Button {
                        submit()
                    } label: {
                        Group {
                            if isSubmitting {
                                ProgressView()
                            } else {
                                Text("Zamítnout recept")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(trimmedReason.isEmpty ? Color.red.opacity(0.35) : Color.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(trimmedReason.isEmpty || isSubmitting)
                }
                .padding()
            }
            .background(AppTheme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
            }
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(isSubmitting)
    }

    private func submit() {
        guard !trimmedReason.isEmpty else { return }
        isSubmitting = true
        isReasonFocused = false
        Task {
            await onConfirm(trimmedReason)
            isSubmitting = false
            dismiss()
        }
    }
}

/// Upozornění v detailu receptu, že ho admin zamítl, včetně důvodu.
/// Zamítnutý recept vidí jen autor (a admin), takže je to zpráva pro autora.
struct RejectionNoticeView: View {

    let reason: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Recept byl zamítnut", systemImage: "xmark.octagon.fill")
                .font(.headline)
                .foregroundStyle(.red)

            if let reason, !reason.isEmpty {
                Text(reason)
                    .foregroundStyle(AppTheme.text)
            } else {
                Text("Důvod nebyl uveden.")
                    .foregroundStyle(AppTheme.mutedText)
            }

            Text("Uprav recept a ulož ho – znovu se odešle ke schválení.")
                .font(.footnote)
                .foregroundStyle(AppTheme.mutedText)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.red.opacity(0.5), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    RejectRecipeSheet(
        recipe: Recipe(
            id: 1,
            title: "Svíčková",
            ingredients: nil,
            instructions: nil,
            category: "Hlavní jídla",
            imageUrl: nil,
            authorUsername: "martin"
        )
    ) { _ in }
}
