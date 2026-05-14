import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 22) {
            
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 34))
                        .foregroundStyle(.white)
                    
                    VStack(alignment: .leading, spacing: -2) {
                        Text("RecAPPy")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("B O O K")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                
                Spacer()
                
                Text("user")
                    .font(.headline)
                    .foregroundStyle(AppTheme.green)
                
                Button("Odhlásit") {
                    print("Odhlášení zatím později")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text("👨‍🍳")
                    .font(.title2)
            }
            
            Text("„Někteří lidé jedí, aby žili. My žijeme, abychom jedli.“")
                .font(.system(size: 17, weight: .semibold))
                .italic()
                .foregroundStyle(AppTheme.green)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
}

#Preview {
    HeaderView()
        .background(AppTheme.background)
}
