import SwiftUI

struct AuthView: View {
    
    @ObservedObject var viewModel: AuthViewModel
    @State private var isRegisterMode = false
    @State private var showForgotPassword = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var formMaxWidth: CGFloat? {
        horizontalSizeClass == .regular ? 460 : nil
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            HeaderView(onLogoTap: {})
            
        
            HStack(spacing: 12) {
                authTabButton(title: "Přihlásit", isActive: !isRegisterMode) {
                    isRegisterMode = false
                }
                
                authTabButton(title: "Registrovat", isActive: isRegisterMode) {
                    isRegisterMode = true
                }
            }
            
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("Uživatelské jméno")
                    TextField("", text: $viewModel.username, prompt: placeholder("Zadejte uživatelské jméno"))
                        .textFieldStyle(.plain)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(AppTheme.text)
                }
                
                if isRegisterMode {
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("E-mail")
                        TextField("", text: $viewModel.email, prompt: placeholder("Zadejte e-mail"))
                            .textFieldStyle(.plain)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(AppTheme.text)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    fieldLabel("Heslo")
                    SecureField("", text: $viewModel.password, prompt: placeholder("Zadejte heslo"))
                        .textFieldStyle(.plain)
                        .padding()
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(AppTheme.text)
                }
                
                Button {
                    Task {
                        if isRegisterMode {
                            await viewModel.register()
                        } else {
                            await viewModel.login()
                        }
                    }
                } label: {
                    Text(isRegisterMode ? "Registrovat" : "Přihlásit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(viewModel.isLoading)
            }
            .frame(maxWidth: formMaxWidth)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !viewModel.successMessage.isEmpty {
                Text(viewModel.successMessage)
                    .foregroundStyle(AppTheme.accent)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Button("Zapomněli jste heslo?") {
                showForgotPassword.toggle()
            }
            .foregroundStyle(AppTheme.blue)

            Button("Pokračovat jako host") {
                viewModel.continueAsGuest()
            }
            .font(.subheadline.bold())
            .foregroundStyle(AppTheme.mutedText)

            if showForgotPassword {
                VStack(spacing: 12) {
                    TextField("", text: $viewModel.email, prompt: placeholder("E-mail pro reset hesla"))
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(AppTheme.text)
                    
                    Button {
                        Task {
                            await viewModel.forgotPassword()
                        }
                    } label: {
                        Text("Poslat odkaz pro reset")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(viewModel.isLoading)
                }
                .frame(maxWidth: formMaxWidth)
            }
            
            Spacer()
            
            FooterView()
        }
        .padding()
        .background(AppTheme.background)
        .dismissKeyboardOnTap()
    }

    private func placeholder(_ text: String) -> Text {
        Text(text).foregroundStyle(Color.white.opacity(0.45))
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.bold())
            .foregroundStyle(AppTheme.mutedText)
            .padding(.leading, 4)
    }

    private func authTabButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(width: 150)
                .padding(.vertical, 12)
                .background(isActive ? AppTheme.green : AppTheme.card)
                .foregroundStyle(isActive ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
}
