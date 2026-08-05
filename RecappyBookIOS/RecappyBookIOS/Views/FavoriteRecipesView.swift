import SwiftUI

struct FavoriteRecipesView: View {

    @StateObject private var viewModel = FavoriteRecipesViewModel()
    @State private var recipeToShow: Recipe?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                Text("Oblíbené recepty")
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

                if !viewModel.isLoading && viewModel.recipes.isEmpty {
                    Text("Zatím nemáš žádné oblíbené recepty.")
                        .foregroundStyle(AppTheme.mutedText)
                        .padding(.horizontal)
                }

                ForEach(viewModel.recipes) { recipe in
                    Button {
                        recipeToShow = recipe
                    } label: {
                        RecipeCardView(
                            recipe: recipe,
                            onFavoriteTap: {
                                Task {
                                    await viewModel.toggleFavorite(for: recipe)
                                }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top)
        }
        .background(AppTheme.background)
        .task {
            await viewModel.loadRecipesIfNeeded()
        }
        .navigationDestination(item: $recipeToShow) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }
}
