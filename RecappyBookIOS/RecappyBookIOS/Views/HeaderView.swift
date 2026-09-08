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

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isPad: Bool { horizontalSizeClass == .regular }
    private var logoIconSize: CGFloat { isPad ? 56 : 34 }
    private var logoTitleSize: CGFloat { isPad ? 40 : 26 }
    private var logoSubtitleSize: CGFloat { isPad ? 20 : 14 }
    private var avatarSize: CGFloat { isPad ? 40 : 24 }
    private var noControlsAvatarSize: CGFloat { isPad ? 44 : 28 }
    private var userButtonNameMaxWidth: CGFloat { isPad ? 140 : 90 }
    
    var body: some View {
        VStack(spacing: 22) {
            
            HStack {
                Button(action: { onLogoTap?() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: logoIconSize, weight: .bold))
                            .foregroundStyle(Color(white: 0.95))

                        VStack(alignment: .leading, spacing: -2) {
                            Text("RecAPPy")
                                .font(.system(size: logoTitleSize, weight: .heavy))
                                .foregroundStyle(Color(white: 0.95))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Text("B O O K")
                                .font(.system(size: logoSubtitleSize, weight: .bold))
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
                            
                            Image("UserAvatar")
                                .resizable()
                                .scaledToFill()
                                .frame(width: avatarSize, height: avatarSize)
                                .clipShape(Circle())
                            
                            Text(username ?? "")
                                .font(isPad ? .headline : .caption.weight(.bold))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: userButtonNameMaxWidth)
                            
                            Image(systemName: "line.3.horizontal")
                                .font(isPad ? .title3 : .caption)
                        }
                        .foregroundStyle(AppTheme.green)
                        .padding(.horizontal, isPad ? 16 : 10)
                        .padding(.vertical, isPad ? 12 : 8)
                        .background(AppTheme.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppTheme.green.opacity(0.25), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    
                } else {
                    
                    Image("UserAvatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: noControlsAvatarSize, height: noControlsAvatarSize)
                        .clipShape(Circle())
                }
            }
            
            Text("„Někteří lidé jedí, aby žili. My žijeme, abychom jedli.“")
                .font(.system(size: 17, weight: .semibold))
                .italic()
                .foregroundStyle(AppTheme.green)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
}

#Preview {
    HeaderView()
        .background(AppTheme.background)
}
