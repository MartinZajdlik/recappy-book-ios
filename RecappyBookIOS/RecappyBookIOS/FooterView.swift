import SwiftUI

struct FooterView: View {
    var body: some View {
        
        VStack(spacing: 4) {
            
            Divider()
                .overlay(Color.white.opacity(0.1))
                .padding(.horizontal, 20)
            
            Text("Kontakt: recappybook@gmail.com")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            
            Text("© RecAPPy Book — Martin Žajdlík © 2025")
                .font(.caption2.weight(.medium))
                .foregroundStyle(AppTheme.text.opacity(0.8))
        }
        .multilineTextAlignment(.center)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

#Preview {
    FooterView()
        .background(AppTheme.background)
}
