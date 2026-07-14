import SwiftUI

struct AdminPendingRecipesView: View {

    @StateObject private var viewModel = AdminPendingRecipesViewModel()
    @State private var recipeToDelete: Recipe?
    @State private var showDeleteAlert = false
    @State private var recipeToShow: Recipe?
    @State private var recipeToEdit: Recipe?

    var body: some View {
        VStack(spacing: 18) {

            Text("Recepty ke schválení")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            if viewModel.isLoading {
                ProgressView("Načítám recepty...")
                    .foregroundStyle(AppTheme.text)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            if !viewModel.isLoading && viewModel.recipes.isEmpty {
                Text("Žádné recepty čekající na schválení.")
                    .foregroundStyle(AppTheme.mutedText)
                    .padding(.horizontal)
            }

            LazyVStack(spacing: 14) {
                ForEach(viewModel.recipes) { recipe in
                    AdminRecipeCardView(
                        recipe: recipe,
                        onShow: {
                            recipeToShow = recipe
                        },
                        onEdit: {
                            recipeToEdit = recipe
                        },
                        onDelete: {
                            recipeToDelete = recipe
                            showDeleteAlert = true
                        },
                        onApprove: {
                            Task {
                                await viewModel.approve(recipe)
                            }
                        },
                        onReject: {
                            Task {
                                await viewModel.reject(recipe)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .task {
            await viewModel.loadRecipesIfNeeded()
        }
        .alert("Smazat recept?", isPresented: $showDeleteAlert) {
            Button("Zrušit", role: .cancel) {}

            Button("Smazat", role: .destructive) {
                if let recipe = recipeToDelete {
                    Task {
                        await viewModel.deleteRecipe(recipe)
                        recipeToDelete = nil
                    }
                }
            }
        } message: {
            Text("Opravdu chceš smazat tento recept?")
        }
        .navigationDestination(item: $recipeToShow) { recipe in
            RecipeDetailView(recipe: recipe)
        }
        .sheet(item: $recipeToEdit) { recipe in
            NavigationStack {
                RecipeFormView(recipe: recipe) {
                    Task {
                        await viewModel.loadRecipes()
                    }
                }
            }
        }
    }
}

#Preview {
    AdminPendingRecipesView()
        .background(AppTheme.background)
}
