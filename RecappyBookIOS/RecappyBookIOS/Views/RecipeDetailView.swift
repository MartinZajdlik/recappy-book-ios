import SwiftUI

struct RecipeDetailView: View {
    
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                
                Text(recipe.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.green)
                
                Text("Kategorie: \(recipe.category ?? "-")")
                    .font(.headline)
                    .italic()
                    .foregroundStyle(.white.opacity(0.75))
                
                if let author = recipe.authorUsername {
                    Text("Autor: \(author)")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedText)
                }
                
                if let imageUrl = recipe.imageUrl,
                   !imageUrl.isEmpty,
                   let url = URL(string: optimizedImageUrl(imageUrl, width: 900)) {
                    
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                        case .failure:
                            Text("Obrázek se nepodařilo načíst")
                                .foregroundStyle(AppTheme.mutedText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)

                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                Text("Ingredience")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.green)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    ForEach(
                        (recipe.ingredients ?? "")
                            .components(separatedBy: ",")
                            .filter { !$0.isEmpty },
                        id: \.self
                    ) { ingredient in
                        
                        HStack(alignment: .top) {
                            
                            Text("•")
                                .foregroundStyle(AppTheme.green)
                            
                            Text(ingredient)
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                Text("Postup")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.green)
                
                Text(recipe.instructions ?? "")
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}
