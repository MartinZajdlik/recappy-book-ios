import SwiftUI

struct HeaderView: View {
    let username: String?
    let showUserControls: Bool
    let onLogoTap: (() -> Void)?
    let onUserMenuTap: (() -> Void)?
    
    init(
        username: String? = nil,
        showUserControls: Bool = false,
        onLogoTap: (() -> Void)? = nil,
        onUserMenuTap: (() -> Void)? = nil
    ) {
        self.username = username
        self.showUserControls = showUserControls
        self.onLogoTap = onLogoTap
        self.onUserMenuTap = onUserMenuTap
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
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
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
                    
                    Button {
                        onUserMenuTap?()
                    } label: {
                        
                        HStack(spacing: 8) {
                            
                            Text("👨‍🍳")
                                .font(.title3)
                            
                            Text(username ?? "")
                                .font(.caption.weight(.bold))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: 90)
                            
                            Image(systemName: "line.3.horizontal")
                                .font(.caption)
                        }
                        .foregroundStyle(AppTheme.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(AppTheme.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppTheme.green.opacity(0.25), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    
                } else {
                    
                    Text("👨‍🍳")
                        .font(.title2)
                }
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
