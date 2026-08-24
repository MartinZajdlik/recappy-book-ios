import SwiftUI

struct AdminRecipesView: View {
    
    @StateObject private var viewModel = AdminRecipesViewModel()
    @State private var recipeToDelete: Recipe?
    @State private var showDeleteAlert = false
    @State private var recipeToShow: Recipe?
    @State private var recipeToEdit: Recipe?

    var body: some View {
        VStack(spacing: 18) {

            Text("Správa receptů")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 8) {
                
                CategoryButtonView(title: "Polévky", icon: "cup.and.saucer.fill") {
                    viewModel.selectCategory("Polévky")
                }
                
                CategoryButtonView(title: "Hlavní\njídla", icon: "fork.knife.circle") {
                    viewModel.selectCategory("Hlavní jídla")
                }
                
                CategoryButtonView(title: "Dezerty", icon: "birthday.cake") {
                    viewModel.selectCategory("Dezerty")
                }
                
                CategoryButtonView(title: "Snídaně", icon: "frying.pan.fill") {
                    viewModel.selectCategory("Snídaně")
                }
                
                CategoryButtonView(title: "Ostatní", icon: "takeoutbag.and.cup.and.straw") {
                    viewModel.selectCategory("Ostatní")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            
            if viewModel.isLoading {
                LoadingStateView(defaultMessage: "Načítám recepty...")
            }

            if let error = viewModel.errorMessage {
                ErrorRetryView(message: error) {
                    Task {
                        await viewModel.loadRecipes()
                    }
                }
            }
            
            LazyVStack(spacing: 14) {
                ForEach(viewModel.filteredRecipes) { recipe in
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

struct AdminRecipeCardView: View {
    
    let recipe: Recipe
    let onShow: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    var onApprove: (() -> Void)? = nil
    var onReject: (() -> Void)? = nil

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {

                    AsyncImage(url: URL(string: optimizedImageUrl(recipe.imageUrl ?? "", width: 300))) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.categoryCard)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundStyle(AppTheme.mutedText)
                            )
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(recipe.title)
                            .font(.headline)
                            .foregroundStyle(AppTheme.text)
                            .lineLimit(2)

                        HStack(spacing: 6) {
                            Text(recipe.category ?? "Bez kategorie")
                                .font(.caption.bold())
                                .foregroundStyle(AppTheme.green)

                            RecipeStatusBadge(status: recipe.status)
                        }

                        if let author = recipe.authorUsername {
                            Text("Autor: \(author)")
                                .font(.caption)
                                .foregroundStyle(AppTheme.mutedText)
                        }


                        Text(recipe.ingredients ?? "")
                            .font(.caption)
                            .foregroundStyle(AppTheme.mutedText)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.mutedText)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                HStack(spacing: 8) {
                    Button("Zobrazit") {
                        onShow()
                    }
                    .buttonStyle(.bordered)

                    Button("Upravit") {
                        onEdit()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Text("Smazat")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))

                if let onApprove, let onReject {
                    HStack(spacing: 8) {
                        Button("Schválit") {
                            onApprove()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                        Button("Zamítnout", role: .destructive) {
                            onReject()
                        }
                        .buttonStyle(.bordered)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding()
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    AdminRecipesView()
        .background(AppTheme.background)
}
