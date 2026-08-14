import SwiftUI

let mealPlanWeekdayNames = ["Pondělí", "Úterý", "Středa", "Čtvrtek", "Pátek", "Sobota", "Neděle"]

func mealPlanDayName(for dayOfWeek: Int) -> String {
    guard dayOfWeek >= 1 && dayOfWeek <= mealPlanWeekdayNames.count else { return "" }
    return mealPlanWeekdayNames[dayOfWeek - 1]
}

struct MealPlanView: View {

    @StateObject private var viewModel = MealPlanViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                Text("Jídelníček")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                VStack(spacing: 12) {
                    ForEach(1...7, id: \.self) { dayOfWeek in
                        NavigationLink {
                            MealPlanDayView(dayOfWeek: dayOfWeek, viewModel: viewModel)
                        } label: {
                            HStack {
                                Text(mealPlanDayName(for: dayOfWeek))
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.text)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(AppTheme.mutedText)
                            }
                            .padding()
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(AppTheme.background)
        .task {
            await viewModel.loadMealPlanIfNeeded()
        }
    }
}
