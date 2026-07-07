import SwiftUI

struct RecipeCardView: View {
    
    let recipe: Recipe
    let onFavoriteTap: (() -> Void)?
    
    var body: some View {
        
        HStack(spacing: 14) {
            
            AsyncImage(url: URL(string: optimizedImageUrl(recipe.imageUrl ?? "", width: 300))) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 82, height: 82)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(recipe.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppTheme.green)
                
                Text("Kategorie: \(recipe.category ?? "-")")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                
                if let author = recipe.authorUsername {
                    Text("Autor: \(author)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedText)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    }
                
            }
            Spacer()
            
            Button {
                onFavoriteTap?()
            } label: {
                Image(systemName: recipe.favorite == true ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundStyle(recipe.favorite == true ? .yellow : .white.opacity(0.7))
            }
            .buttonStyle(.plain)
            
          
        }
        .padding(16)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 14)
    }
}

#Preview {
    RecipeCardView(
        recipe: Recipe(
            id: 1,
            title: "Burger",
            ingredients: "Maso",
            instructions: "Postup",
            category: "Hlavní jídla",
            imageUrl: nil,
            authorUsername: "martin",
            favorite: false
        ),
        onFavoriteTap: {}
    )
    .background(AppTheme.background)
}
