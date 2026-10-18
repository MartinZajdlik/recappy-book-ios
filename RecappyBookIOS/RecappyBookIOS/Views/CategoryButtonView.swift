import SwiftUI

struct CategoryButtonView: View {
    
    let title: String
    let icon: String
    /// Vybraná kategorie dostane tenký zelený rámeček (stejný jako aktivní vyhledávání).
    var isSelected: Bool = false
    let action: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isPad: Bool { horizontalSizeClass == .regular }
    private var cardWidth: CGFloat { isPad ? 92 : 62 }
    private var cardHeight: CGFloat { isPad ? 106 : 72 }
    private var iconSize: CGFloat { isPad ? 30 : 20 }
    private var titleSize: CGFloat { isPad ? 15 : 11 }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: isPad ? 10 : 8) {
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.system(size: titleSize, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: cardWidth, height: cardHeight)
            .background(AppTheme.categoryCard)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? AppTheme.green.opacity(0.6) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    CategoryButtonView(title: "Polévky", icon: "fork.knife", action: {})
        .background(AppTheme.background)
}
