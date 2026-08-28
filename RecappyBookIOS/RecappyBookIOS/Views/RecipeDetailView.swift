import SwiftUI
import UIKit

struct RecipeDetailView: View {

    let recipe: Recipe

    @State private var isScreenAwakeEnabled: Bool = false
    @State private var willResignActiveObserver: NSObjectProtocol?
    @State private var didBecomeActiveObserver: NSObjectProtocol?

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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isScreenAwakeEnabled.toggle()
                    UIApplication.shared.isIdleTimerDisabled = isScreenAwakeEnabled
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isScreenAwakeEnabled ? "sun.max.fill" : "sun.max")
                        Text(isScreenAwakeEnabled ? "Displej svítí" : "Nezhasínat")
                    }
                    .font(.caption)
                    .foregroundStyle(isScreenAwakeEnabled ? AppTheme.green : AppTheme.mutedText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isScreenAwakeEnabled ? AppTheme.green.opacity(0.15) : AppTheme.categoryCard)
                    )
                    .overlay(
                        Capsule()
                            .stroke(isScreenAwakeEnabled ? AppTheme.green : Color.clear, lineWidth: 1)
                    )
                }
            }
        }
        .onAppear {
            willResignActiveObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil,
                queue: .main
            ) { _ in
                UIApplication.shared.isIdleTimerDisabled = false
            }
            didBecomeActiveObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { _ in
                if isScreenAwakeEnabled {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            if let token = willResignActiveObserver {
                NotificationCenter.default.removeObserver(token)
                willResignActiveObserver = nil
            }
            if let token = didBecomeActiveObserver {
                NotificationCenter.default.removeObserver(token)
                didBecomeActiveObserver = nil
            }
        }
    }
}
