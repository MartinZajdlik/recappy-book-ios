import SwiftUI

struct MyRecipesView: View {

    @StateObject private var viewModel = MyRecipesViewModel()

    @State private var recipeToShow: Recipe?
    @State private var recipeToEdit: Recipe?
    @State private var recipeToDelete: Recipe?
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                Text("Moje recepty")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.green)

                if viewModel.isLoading {
                    ProgressView()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

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
                        }
                    )
                }
            }
            .padding()
        }
        .background(AppTheme.background)
        .task {
            await viewModel.loadRecipes()
        }
        .sheet(item: $recipeToShow) { recipe in
            NavigationStack {
                RecipeDetailView(recipe: recipe)
            }
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
        .alert("Smazat recept?", isPresented: $showDeleteAlert) {
            Button("Zrušit", role: .cancel) {}

            Button("Smazat", role: .destructive) {
                if let recipe = recipeToDelete {
                    Task {
                        do {
                            try await APIService.shared.deleteRecipe(recipeId: recipe.id)
                            await viewModel.loadRecipes()
                            recipeToDelete = nil
                        } catch {
                            viewModel.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        } message: {
            Text("Opravdu chceš smazat tento recept?")
        }
    }
}
