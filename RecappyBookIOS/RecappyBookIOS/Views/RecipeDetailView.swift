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
                
                if let imageUrl = recipe.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
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
