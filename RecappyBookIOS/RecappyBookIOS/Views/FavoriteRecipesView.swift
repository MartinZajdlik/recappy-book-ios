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

                if viewModel.isLoading {
                    ProgressView()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

                if !viewModel.isLoading && viewModel.recipes.isEmpty {
                    Text("Zatím nemáš žádné oblíbené recepty.")
                        .foregroundStyle(AppTheme.mutedText)
                }

                ForEach(viewModel.recipes) { recipe in
                    Button {
                        recipeToShow = recipe
                    } label: {
                        RecipeCardView(
                            recipe: recipe,
                            onFavoriteTap: {}
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(AppTheme.background)
        .task {
            await viewModel.loadRecipesIfNeeded()
        }
        .sheet(item: $recipeToShow) { recipe in
            NavigationStack {
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
