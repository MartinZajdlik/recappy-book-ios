import SwiftUI

struct AdminRecipesView: View {
    
    @StateObject private var viewModel = AdminRecipesViewModel()
    @State private var recipeToDelete: Recipe?
    @State private var showDeleteAlert = false
    @State private var recipeToShow: Recipe?
    @State private var showAddForm = false
    @State private var recipeToEdit: Recipe?
    
    var body: some View {
        VStack(spacing: 18) {
            
            Button {
                showAddForm = true
            } label: {
                Text("+ Přidat recept")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.green)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
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
                ProgressView("Načítám recepty...")
                    .foregroundStyle(AppTheme.text)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
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
        .sheet(isPresented: $showAddForm) {
            NavigationStack {
                RecipeFormView(recipe: nil) {
                    Task {
                        await viewModel.loadRecipes()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showAddForm = false
                        } label: {
                            Label("Zpět", systemImage: "chevron.left")
                        }
                    }
                }
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
    }
}

struct AdminRecipeCardView: View {
    
    let recipe: Recipe
    let onShow: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
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
                    
                    Text(recipe.category ?? "Bez kategorie")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.green)
                    
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
            }
            
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
