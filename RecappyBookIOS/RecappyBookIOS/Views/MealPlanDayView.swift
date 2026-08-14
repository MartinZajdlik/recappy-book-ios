import SwiftUI

struct MealPlanDayView: View {

    let dayOfWeek: Int
    @ObservedObject var viewModel: MealPlanViewModel

    @State private var isEditing = false
    @State private var isSaving = false

    @State private var draftBreakfast = ""
    @State private var draftSnack1 = ""
    @State private var draftLunch = ""
    @State private var draftSnack2 = ""
    @State private var draftDinner = ""

    private var currentEntry: MealPlanEntry {
        viewModel.entry(forDay: dayOfWeek)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                Text(mealPlanDayName(for: dayOfWeek))
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.green)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

                mealRow(title: "Snídaně", savedValue: currentEntry.breakfast, draft: $draftBreakfast)
                mealRow(title: "Svačina", savedValue: currentEntry.snack1, draft: $draftSnack1)
                mealRow(title: "Oběd", savedValue: currentEntry.lunch, draft: $draftLunch)
                mealRow(title: "Svačina", savedValue: currentEntry.snack2, draft: $draftSnack2)
                mealRow(title: "Večeře", savedValue: currentEntry.dinner, draft: $draftDinner)

                if isEditing {
                    HStack(spacing: 12) {
                        Button {
                            isEditing = false
                        } label: {
                            Text("Zrušit")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.categoryCard)
                                .foregroundStyle(AppTheme.text)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(isSaving)

                        Button {
                            save()
                        } label: {
                            if isSaving {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Uložit")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(AppTheme.green)
                        .foregroundStyle(AppTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .disabled(isSaving)
                    }
                } else {
                    Button {
                        startEditing()
                    } label: {
                        Text("Upravit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.green)
                            .foregroundStyle(AppTheme.background)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background)
    }

    private func startEditing() {
        draftBreakfast = currentEntry.breakfast ?? ""
        draftSnack1 = currentEntry.snack1 ?? ""
        draftLunch = currentEntry.lunch ?? ""
        draftSnack2 = currentEntry.snack2 ?? ""
        draftDinner = currentEntry.dinner ?? ""
        isEditing = true
    }

    private func save() {
        isSaving = true
        Task {
            let success = await viewModel.saveDay(
                dayOfWeek: dayOfWeek,
                breakfast: draftBreakfast,
                snack1: draftSnack1,
                lunch: draftLunch,
                snack2: draftSnack2,
                dinner: draftDinner
            )
            isSaving = false
            if success {
                isEditing = false
            }
        }
    }

    @ViewBuilder
    private func mealRow(title: String, savedValue: String?, draft: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.green)

            if isEditing {
                TextEditor(text: draft)
                    .frame(minHeight: 80)
                    .padding(6)
                    .background(AppTheme.categoryCard)
                    .foregroundStyle(AppTheme.text)
                    .scrollContentBackground(.hidden)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                let hasContent = savedValue?.isEmpty == false
                Text(hasContent ? savedValue! : "Nevyplněno")
                    .foregroundStyle(hasContent ? AppTheme.text : AppTheme.mutedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
