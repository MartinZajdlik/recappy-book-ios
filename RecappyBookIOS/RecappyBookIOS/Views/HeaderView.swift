import SwiftUI

struct HeaderView: View {
    let username: String?
    let showUserControls: Bool
    let onLogoTap: (() -> Void)?
    let onLogoutTap: (() -> Void)?
    
    init(
        username: String? = nil,
        showUserControls: Bool = false,
        onLogoTap: (() -> Void)? = nil,
        onLogoutTap: (() -> Void)? = nil
    ) {
        self.username = username
        self.showUserControls = showUserControls
        self.onLogoTap = onLogoTap
        self.onLogoutTap = onLogoutTap
    }
    
    var body: some View {
        VStack(spacing: 22) {
            
            HStack {
                Button(action: { onLogoTap?() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(Color(white: 0.95))
                        
                        VStack(alignment: .leading, spacing: -2) {
                            Text("RecAPPy")
                                .font(.system(size: 26, weight: .heavy))
                                .foregroundStyle(Color(white: 0.95))
                            
                            Text("B O O K")
                                .font(.system(size: 14, weight: .bold))
                                .kerning(3)
                                .foregroundStyle(Color(white: 0.95))
                        }
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                if showUserControls {
                    Text(username ?? "")
                        .font(.headline)
                        .foregroundStyle(AppTheme.green)
                    
                    Button("Odhlásit") {
                        onLogoutTap?()
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
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
