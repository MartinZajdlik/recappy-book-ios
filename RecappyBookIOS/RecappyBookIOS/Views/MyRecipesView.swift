import SwiftUI

struct MyRecipesView: View {

    @StateObject private var viewModel = MyRecipesViewModel()

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
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(AppTheme.background)
        .task {
            await viewModel.loadRecipes()
        }
    }
}
