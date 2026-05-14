import SwiftUI

struct CategoryButtonView: View {
    
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 62, height: 72)
            .background(AppTheme.categoryCard)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    CategoryButtonView(title: "Polévky", icon: "fork.knife", action: {})
        .background(AppTheme.background)
}
