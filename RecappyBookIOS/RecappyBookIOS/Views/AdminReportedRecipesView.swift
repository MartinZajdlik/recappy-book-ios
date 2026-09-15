import SwiftUI

struct AdminReportedRecipesView: View {

    @StateObject private var viewModel = AdminReportedRecipesViewModel()
    @State private var reportToDelete: ReportedRecipe?
    @State private var showDeleteAlert = false
    @State private var reportToShow: ReportedRecipe?
    @State private var reportToEdit: ReportedRecipe?
    var onStatusChange: () -> Void = {}

    var body: some View {
        VStack(spacing: 18) {

            Text("Nahlášené recepty")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            if viewModel.isLoading {
                LoadingStateView(defaultMessage: "Načítám nahlášení...")
            }

            if let error = viewModel.errorMessage {
                ErrorRetryView(message: error) {
                    Task {
                        await viewModel.loadReports()
                    }
                }
            }

            if !viewModel.isLoading && viewModel.reports.isEmpty {
                Text("Žádné nevyřízené nahlášení.")
                    .foregroundStyle(AppTheme.mutedText)
                    .padding(.horizontal)
            }

            LazyVStack(spacing: 14) {
                ForEach(viewModel.reports) { report in
                    AdminRecipeCardView(
                        recipe: report.asRecipe,
                        onShow: {
                            reportToShow = report
                        },
                        onEdit: {
                            reportToEdit = report
                        },
                        onDelete: {
                            reportToDelete = report
                            showDeleteAlert = true
                        },
                        reportCount: report.reportCount,
                        onDismissReport: {
                            Task {
                                await viewModel.dismiss(report)
                                onStatusChange()
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .task {
            await viewModel.loadReportsIfNeeded()
        }
        .alert("Smazat recept?", isPresented: $showDeleteAlert) {
            Button("Zrušit", role: .cancel) {}

            Button("Smazat", role: .destructive) {
                if let report = reportToDelete {
                    Task {
                        await viewModel.delete(report)
                        onStatusChange()
                        reportToDelete = nil
                    }
                }
            }
        } message: {
            Text("Opravdu chceš tento recept smazat? Tuto akci nejde vrátit zpět.")
        }
        .navigationDestination(item: $reportToShow) { report in
            RecipeDetailView(recipe: report.asRecipe)
        }
        .sheet(item: $reportToEdit) { report in
            NavigationStack {
                RecipeFormView(recipe: report.asRecipe) {
                    Task {
                        await viewModel.loadReports()
                    }
                }
            }
        }
    }
}

#Preview {
    AdminReportedRecipesView()
        .background(AppTheme.background)
}
