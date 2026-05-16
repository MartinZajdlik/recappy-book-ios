import SwiftUI

struct FooterView: View {
    var body: some View {
        VStack(spacing: 8) {
            Divider()
                .overlay(Color.white.opacity(0.1))
                .padding(.horizontal, 14)
            
            Text("Kontakt: recappybook@gmail.com")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("© RecAPPy Book — Martin Žajdlík © 2025")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppTheme.text.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 16)
        .padding(.bottom, 8)
        .background(AppTheme.background.opacity(0.001))
    }
}

#Preview {
    FooterView()
        .background(AppTheme.background)
}
